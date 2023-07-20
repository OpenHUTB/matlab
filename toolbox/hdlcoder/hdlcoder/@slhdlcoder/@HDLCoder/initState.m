function initState(this)


    this.SubModelData=[];
    this.SequentialContext=false;


    this.CurrentClock=[];
    this.CurrentClockEnable=[];
    this.CurrentReset=[];
    this.HasClockEnable=true;


    delete(get(this,'TimingControllerInfo'));
    set(this,'TimingControllerInfo',[]);



    hdluniqueprocessname(0);
    hdluniquename(0,1);
