function constructObject(this,modelH,systemH)


    if nargin<3
        systemH=modelH;
    end

    this.pslinkcc=pslink.ConfigComp();
    if~isempty(modelH)
        try
            actCoder=pssharedprivate('getCoderID',systemH);
            if~isempty(actCoder)
                this.coderKind=actCoder;
            else
                this.coderKind='unknown';
            end
            pslinkcc=pssharedprivate('getConfigComp',modelH);
            if~isempty(pslinkcc)
                this.pslinkcc=pslinkcc;
                L(1)=handle.listener(this.pslinkcc,'ObjectBeingDestroyed',@pslinkccDestroyed);
                L(1).CallbackTarget=this;
                this.pslinkccListeners=L(1);
            end
        catch Me %#ok<NASGU>

            this.pslinkcc=pslink.ConfigComp();
        end
    end


    addForwardedProperty(this,'ResultDir','on','on','on');
    addForwardedProperty(this,'VerificationSettings','on','on','on');
    addForwardedProperty(this,'OpenProjectManager','on','on','on',true);
    addForwardedProperty(this,'AddSuffixToResultDir','on','on','on',true);
    addForwardedProperty(this,'EnableAdditionalFileList','on','on','on',true);
    addForwardedProperty(this,'AdditionalFileList','on','on','on');
    addForwardedProperty(this,'VerificationMode','on','on','on');
    addForwardedProperty(this,'EnablePrjConfigFile','on','on','on',true);
    addForwardedProperty(this,'PrjConfigFile','on','on','on');
    addForwardedProperty(this,'AddToSimulinkProject','on','on','on',true);
    addForwardedProperty(this,'InputRangeMode','on','on','on');
    addForwardedProperty(this,'ParamRangeMode','on','on','on');
    addForwardedProperty(this,'OutputRangeMode','on','on','on');
    addForwardedProperty(this,'ModelRefVerifDepth','on','on','on');
    addForwardedProperty(this,'ModelRefByModelRefVerif','on','on','on',true);
    addForwardedProperty(this,'AutoStubLUT','on','on','on',true);
    addForwardedProperty(this,'CxxVerificationSettings','on','on','on');
    addForwardedProperty(this,'CheckConfigBeforeAnalysis','on','on','on');
    addForwardedProperty(this,'VerifAllSFcnInstances','on','on','on',true);



    function val=getForwardedProp(varargin)


        this=varargin{1};
        UDDProp=varargin{3};
        forceBool=varargin{4};
        val=this.pslinkcc.(['PS',UDDProp]);
        if forceBool
            val=pslink.ConfigComp.pConvertToBool(val);
        end


        function val=setForwardedProp(varargin)


            this=varargin{1};
            val=varargin{2};
            UDDProp=varargin{3};
            this.pslinkcc.(['PS',UDDProp])=val;


            function addForwardedProperty(this,propName,publicSet,publicGet,visible,forceBool)

                if nargin<6
                    forceBool=false;
                end

                origProp=findprop(this.pslinkcc,['PS',propName]);
                if isempty(findprop(this,propName))&&~isempty(origProp)
                    dType=origProp.DataType;
                    if forceBool
                        dType='bool';
                    end
                    p=schema.prop(this,propName,dType);
                    p.AccessFlags.PublicSet=publicSet;
                    p.AccessFlags.PublicGet=publicGet;
                    p.Visible=visible;
                    if forceBool
                        p.FactoryValue=pslink.ConfigComp.pConvertToBool(origProp.FactoryValue);
                    else
                        p.FactoryValue=origProp.FactoryValue;
                    end
                    p.SetFunction={@setForwardedProp,propName,forceBool};
                    p.GetFunction={@getForwardedProp,propName,forceBool};
                end


