classdef CommSource<matlab.mixin.SetGet&matlab.mixin.Copyable































    properties(SetObservable)

        CosimBypass(1,1)int16{mustBeReal}=0;

        CommShowInfo(1,1)logical=false;

        CommLocal(1,1)logical=false;

        CommHostName{matlab.internal.validation.mustBeASCIICharRowVector(CommHostName,'CommHostName')}='';

        CommSharedMemory{matlab.internal.validation.mustBeASCIICharRowVector(CommSharedMemory,'CommSharedMemory')}='Socket';

        CommPortNumber{matlab.internal.validation.mustBeASCIICharRowVector(CommPortNumber,'CommPortNumber')}='';

        localHostName{matlab.internal.validation.mustBeASCIICharRowVector(localHostName,'localHostName')}='';

        lastRemoteHostName{matlab.internal.validation.mustBeASCIICharRowVector(lastRemoteHostName,'lastRemoteHostName')}='';

        CommName{matlab.internal.validation.mustBeASCIICharRowVector(CommName,'CommName')}='';

        LocalTag{matlab.internal.validation.mustBeASCIICharRowVector(LocalTag,'LocalTag')}='';

        SharedMemTag{matlab.internal.validation.mustBeASCIICharRowVector(SharedMemTag,'SharedMemTag')}='';

        PortNumberTag{matlab.internal.validation.mustBeASCIICharRowVector(PortNumberTag,'PortNumberTag')}='';

        HostNameTag{matlab.internal.validation.mustBeASCIICharRowVector(HostNameTag,'HostNameTag')}='';

        ShowInfoTag{matlab.internal.validation.mustBeASCIICharRowVector(ShowInfoTag,'ShowInfoTag')}='';

        BypassTag{matlab.internal.validation.mustBeASCIICharRowVector(BypassTag,'BypassTag')}='';

        SharedMemTxtTag{matlab.internal.validation.mustBeASCIICharRowVector(SharedMemTxtTag,'SharedMemTxtTag')}='';

        PortNumberTxtTag{matlab.internal.validation.mustBeASCIICharRowVector(PortNumberTxtTag,'PortNumberTxtTag')}='';

        HostNameTxtTag{matlab.internal.validation.mustBeASCIICharRowVector(HostNameTxtTag,'HostNameTxtTag')}='';

        UddUtil=[];
    end

    methods
        function this=CommSource(name,srcData)
            this.UddUtil=hdllinkddg.UddUtil;
            this.CommName=name;
            this.LocalTag=[this.CommName,'.CommLocal'];
            this.SharedMemTag=[this.CommName,'.CommSharedMemory'];
            this.PortNumberTag=[this.CommName,'.CommPortNumber'];
            this.HostNameTag=[this.CommName,'.CommHostName'];
            this.ShowInfoTag=[this.CommName,'.CommShowInfo'];
            this.BypassTag=[this.CommName,'.CosimBypass'];
            this.SharedMemTxtTag=[this.CommName,'.CommSharedMemoryTxt'];
            this.PortNumberTxtTag=[this.CommName,'.CommPortNumberTxt'];
            this.HostNameTxtTag=[this.CommName,'.CommHostNameTxt'];
            this.SetSourceData(srcData);
        end
    end

    methods
        function set.CosimBypass(obj,value)


            obj.CosimBypass=value;
        end

        function set.CommShowInfo(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','CommShowInfo')
            value=logical(value);
            obj.CommShowInfo=value;
        end

        function set.CommLocal(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','CommLocal')
            value=logical(value);
            obj.CommLocal=value;
        end

        function set.CommHostName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.CommHostName=value;
        end

        function set.CommSharedMemory(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            value=validatestring(value,{'Socket','Shared Memory'},'','CommSharedMemory');
            obj.CommSharedMemory=value;
        end

        function set.CommPortNumber(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','CommPortNumber')
            obj.CommPortNumber=value;
        end

        function set.localHostName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','localHostName')
            obj.localHostName=value;
        end

        function set.lastRemoteHostName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','lastRemoteHostName')
            obj.lastRemoteHostName=value;
        end

        function set.CommName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','CommName')
            obj.CommName=value;
        end

        function set.LocalTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','LocalTag')
            obj.LocalTag=value;
        end

        function set.SharedMemTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','SharedMemTag')
            obj.SharedMemTag=value;
        end

        function set.PortNumberTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','PortNumberTag')
            obj.PortNumberTag=value;
        end

        function set.HostNameTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','HostNameTag')
            obj.HostNameTag=value;
        end

        function set.ShowInfoTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','ShowInfoTag')
            obj.ShowInfoTag=value;
        end

        function set.BypassTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','BypassTag')
            obj.BypassTag=value;
        end

        function set.SharedMemTxtTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','SharedMemTxtTag')
            obj.SharedMemTxtTag=value;
        end

        function set.PortNumberTxtTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','PortNumberTxtTag')
            obj.PortNumberTxtTag=value;
        end

        function set.HostNameTxtTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','HostNameTxtTag')
            obj.HostNameTxtTag=value;
        end

        function set.UddUtil(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','UddUtil')
            obj.UddUtil=value;
        end
    end

    methods
        srcData=GetSourceData(this)
        OnWidgetChangeCB(this,tag,dlg,value)
        RefreshWidgets(this,dlg)
        SetSourceData(this,srcData)
    end

    methods(Hidden)

        commGroup=CreateCommWidget(this)
        info=GetConnInfo(this)
        [ens,vis]=GetEnablesAndVisibilities(this)
    end
end

