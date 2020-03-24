contract RS is EthcEvents{
using SafeMath for *;


struct  Player {

    uint256 pID; 
    address payable addr;
    uint256 affId;
    uint256 totalBet;
    uint256 curGen; 
    uint256 curAff; 
    string  inviteCode;
    uint256 lastBet; 
    uint256 lastReleaseTime; 
    uint256 createTime; 

    uint256 baseGen; 
    uint256 baseAff; 
    uint256 baseAffed; 
    uint256 invites;
}
 
 mapping (uint256 => uint256[]) public bdUser_;                 
 mapping (uint256 => mapping(uint256 => uint256)) public bdResults_;
 uint256 public bdRound_ = 1;
 uint256 public bdPot_ = 0;
 uint256 public bdePotDaoshuTime_ = 720 hours;
 uint256 public bdPotDaoshuStartTime_ = 0;
 
 uint256[40] affRate = [300,150,100,70,50,50,50,50,50,50,20,20,20,20,20,20,20,20,20,20,5,5,5,5,5,5,5,5,5,5,2,2,2,2,2,2,2,2,2,2];
 

 
uint256 public luckyPot_ = 0;
uint256 public openLuckycc_ = 100;
uint256  public  luckyRound_ = 1;


uint256 public zhuoyuePot_ = 0;
uint256 public zuoyuePotDaoshuTime_ = 240 hours;
uint256 public zuoyuePotDaoshuStartTime_ = 0;
uint256  public  zhuoyueRound_ = 1;

uint256 public bxTotalCoin = 0;
uint256 public bxStartTime_ = 0;
uint256 public bxTime_ = 72 hours;
 
 
constructor()
public
{
    levelReward_[1] = levelReward(6,1,20,1);
    levelReward_[2] = levelReward(8,10,25,3);
    levelReward_[3] = levelReward(10,20,30,6);
    levelReward_[4] = levelReward(12,40,35,10);
    bxStartTime_ = now;
    bdPotDaoshuStartTime_ = now;
    zuoyuePotDaoshuStartTime_ = now;
}

function buyCore(uint256 _pID,uint256 _eth)
    private
{
    
     
   uint256 _com = _eth.mul(2)/100;
    if(_com>0){
        bose.transfer(_com);
    }
    
    if(now - bxStartTime_ >= bxTime_){
        
        bxStartTime_ = now;
        bxTotalCoin = 0;
    }
    
    
    uint256 _baoxian = _eth.mul(3)/100;
    if(_baoxian>0){
        
        bx.transfer(_baoxian);
        bxTotalCoin = bxTotalCoin.add(_baoxian);
        bxStartTime_ = now;
    }
    
  
    gBet_ = gBet_.add(_eth);
    gBetcc_= gBetcc_ + 1; 
    
   
    dealwithBdPot(_eth);
    if(plyr_[_pID].affId >0){
        insertBdBaseUser(plyr_[_pID].affId,_eth);
    }
    
    
    dealwithluckyPot(_pID,_eth);
    dealwithZhuoyuePot(_eth);
    
    checkOut(_pID);
    
    plyr_[_pID].totalBet = _eth.add(plyr_[_pID].totalBet);
    plyr_[_pID].lastBet  = _eth;
    plyrReward_[_pID].reward =plyrReward_[_pID].reward.add(_eth.mul(levelReward_[getLevel(_eth)].leverage)/10);

    

    
    uint256 _curBaseGen = _eth.mul(levelReward_[getLevel(_eth)].genRate) /1000;
    plyr_[_pID].baseGen = plyr_[_pID].baseGen.add(_curBaseGen);

    
    affUpdate(_pID,_curBaseGen,0,1);
 

    
    plyrReward_[_pID].level = getLevel(plyr_[_pID].totalBet);
  
    plyr_[_pID].lastReleaseTime = now;
  


   
}


function checkInviteCode(string memory _code)  public view returns(uint256 _pID){
    
    _pID = pIDInviteCode_[_code];
    
}

 
function getLevel (uint256 _betEth) 
public
view
returns(uint8 level) 
{
    uint8 _level = 0;
     if(_betEth>=31 * ethWei){
        _level = 4;

    }else if(_betEth>=11 * ethWei){
        _level = 3;

    }else if(_betEth>=6 * ethWei){
        _level = 2;

    }else if(_betEth>=1 * ethWei){
        _level = 1;

    }
    return _level;
}

 
function getDeepForUser(uint256 _pID,uint256 _level)
view
public
returns(uint256 deep){
    
    deep = 0;
    
    if(_level ==4 ){
        if(plyr_[_pID].invites >=10){
            deep = 40;
        }else if(plyr_[_pID].invites >=6){
             deep = 20;
        }else if(plyr_[_pID].invites >=3){
             deep = 10;
        }else if(plyr_[_pID].invites >=1){
             deep = 1;
        }
        
    }else if(_level ==3 ){
        
       if(plyr_[_pID].invites >=6){
             deep = 20;
        }else if(plyr_[_pID].invites >=3){
             deep = 10;
        }else if(plyr_[_pID].invites >=1){
             deep = 1;
        }
        
    }else if(_level ==2 ){
        
        if(plyr_[_pID].invites >=3){
             deep = 10;
        }else if(plyr_[_pID].invites >=1){
             deep = 1;
        }
        
    }else if(_level ==1 ){
        
        if(plyr_[_pID].invites >=1){
             deep = 1;
        }
        
    }
}
 
function getPlayerlaByAddr (address _addr)
public
view
returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256)
{
    uint256 _pID = pIDxAddr_[_addr];
    
    (uint256 _gen,uint256 _aff,) = getUserRewardByBase(_pID);
    
    uint256 totalGenH =  plyrReward_[_pID].totalGen - plyrReward_[_pID].withDrawEdGen + _gen;
    uint256 totalAffH =  plyrReward_[_pID].totalAff - plyrReward_[_pID].withDrawEdAff + _aff;
    
    return(
        _pID,
        plyrReward_[_pID].reward.sub(plyr_[_pID].curGen + plyr_[_pID].curAff+_gen+_aff)>0?plyrReward_[_pID].reward.sub(plyr_[_pID].curGen + plyr_[_pID].curAff+_gen+_aff):0,
        plyrReward_[_pID].totalGen + _gen,
        plyrReward_[_pID].totalAff + _aff,
        totalGenH,
        totalAffH,
        withDrawSet_[_pID].shengyu,
        plyr_[_pID].baseGen,
        plyr_[_pID].baseAff,
        affBijiao_[zhuoyueRound_][_pID]
        
        );


}

 
function getPlayerlaById (uint256 _pID)
public
view
returns(uint256 affid,address addr,uint256 totalBet,uint256 level,uint256 _zypot,uint256 _bdpot,uint256 _luckpot,string memory inviteCode,string memory affInviteCode)
{
   require(_pID>0 && _pID < nextId_, "Now cannot withDraw!");
   
    affid =  plyr_[_pID].affId;
    addr  = plyr_[_pID].addr;
    totalBet = plyr_[_pID].totalBet;
    level = plyrReward_[_pID].level;
    _zypot = playerPot_[_pID].zhuoyuepot;
    _bdpot = playerPot_[_pID].bdpot;
    _luckpot = playerPot_[_pID].luckpot;
  
    inviteCode = plyr_[_pID].inviteCode;
    affInviteCode =plyr_[plyr_[_pID].affId].inviteCode;
      


}

 
function somethingmsg () 
public
view
returns(uint256 _withdrawPt,uint8 _withdrawCcMax,uint256 _withdrawRate,uint256 _withrawBetmin,uint256 _minbeteth,uint256 _genReleTime)
{
    return(
        withdrawPt,
        withdrawCcMax,
        withdrawRate,
        withrawBetmin,
        minbeteth_,
        genReleTime_
        );

}

 

function getsystemMsg()
public
view
returns(uint256 _gbet,uint256 _gcc,uint256 _luckpot,uint256 _zypot,uint256 _zytime,uint256 _bxTotalCoin,uint256 _luckround,uint256 _zyround,uint256 _bdround,uint256 _bdPot,uint256 _bdtime,uint256 _bxTime)
{
    return
    (
        gBet_,
        gBetcc_,
        luckyPot_,
        zhuoyuePot_,
        zuoyuePotDaoshuTime_+zuoyuePotDaoshuStartTime_,
        bxTotalCoin,
        luckyRound_,
        zhuoyueRound_,
        bdRound_,
        bdPot_,
        bdPotDaoshuStartTime_ + bdePotDaoshuTime_,
        bxStartTime_ + bxTime_
        
        
    );
}
}
