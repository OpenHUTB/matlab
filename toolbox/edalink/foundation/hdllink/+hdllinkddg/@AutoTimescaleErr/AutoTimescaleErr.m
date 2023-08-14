classdef AutoTimescaleErr<matlab.mixin.SetGet&matlab.mixin.Copyable

















    properties(SetObservable)

        productName{matlab.internal.validation.mustBeASCIICharRowVector(productName,'productName')}='';

        dialogTag{matlab.internal.validation.mustBeASCIICharRowVector(dialogTag,'dialogTag')}='';

        msgType{matlab.internal.validation.mustBeASCIICharRowVector(msgType,'msgType')}='';

        msg{matlab.internal.validation.mustBeASCIICharRowVector(msg,'msg')}='';

        dmsg{matlab.internal.validation.mustBeASCIICharRowVector(dmsg,'dmsg')}='';

        showShowBtn(1,1)logical=false;

        dmsgTag{matlab.internal.validation.mustBeASCIICharRowVector(dmsgTag,'dmsgTag')}='';

        showBtnTag{matlab.internal.validation.mustBeASCIICharRowVector(showBtnTag,'showBtnTag')}='';

        hideBtnTag{matlab.internal.validation.mustBeASCIICharRowVector(hideBtnTag,'hideBtnTag')}='';
    end

    methods
        function this=AutoTimescaleErr(productName,dialogTag,msgType,msg,dmsg)





            this.productName=productName;
            this.dialogTag=dialogTag;
            this.msgType=msgType;
            this.msg=msg;
            this.dmsg=dmsg;
            if(isempty(dmsg))
                this.showShowBtn=false;
            else
                this.showShowBtn=true;
            end
            this.dmsgTag='dmsgTag';
            this.showBtnTag='showBtnTag';
            this.hideBtnTag='hideBtnTag';

        end
    end

    methods
        function set.productName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','productName')
            obj.productName=value;
        end

        function set.dialogTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','dialogTag')
            obj.dialogTag=value;
        end

        function set.msgType(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','msgType')
            obj.msgType=value;
        end

        function set.msg(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','msg')
            obj.msg=value;
        end

        function set.dmsg(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','dmsg')
            obj.dmsg=value;
        end

        function set.showShowBtn(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','showShowBtn')
            value=logical(value);
            obj.showShowBtn=value;
        end

        function set.dmsgTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','dmsgTag')
            obj.dmsgTag=value;
        end

        function set.showBtnTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','showBtnTag')
            obj.showBtnTag=value;
        end

        function set.hideBtnTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','hideBtnTag')
            obj.hideBtnTag=value;
        end
    end

    methods

        ShowHideBtnCb(this,dialog)
    end


    methods(Hidden)

        dlgStruct=getDialogSchema(this,dummy)
    end
end

