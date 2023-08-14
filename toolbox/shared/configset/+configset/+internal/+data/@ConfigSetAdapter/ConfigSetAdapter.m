classdef ConfigSetAdapter<handle





    events


CSEvent
    end
    properties
Host
    end
    properties(Dependent)
Source
    end
    properties(Hidden)
Views
        fPropListener={}
tlcInfo
tlcCategory
        tlcCreated=false

modelInfo

        inDialogUpdate=false



toolchainInfo
compList

tmpWidgetValues


        debugMode=false;

        viewCount=0;


        needUpdateOverride=false;

        inReset=false;
    end
    properties(Access=?configset.dialog.ConfigSetView)
        params={}
    end
    properties(Access=private)
        serviceOn=false
        locked=false
        BaseConfigClassID='Simulink.BaseConfig'
    end

    methods
        function obj=ConfigSetAdapter(cs,varargin)
            obj.Host=cs;
            obj.tmpWidgetValues=containers.Map;
            if feature('SimulinkBaseConfigU2M')==2
                obj.BaseConfigClassID='qe.BaseConfig';
            end

            if isa(cs,'Simulink.ConfigSetRef')

                cs.populateLocalConfigSet(true);
                if~isempty(cs.LocalConfigSet)
                    cs=cs.LocalConfigSet;
                end
            end

            if nargin==1
                obj.setupTLC(cs);
            end
        end

        function out=get.Source(obj)


            out=obj.Host;
            if isa(out,'Simulink.ConfigSetDialogController')
                out=out.getSourceObject;
            end
        end

        function cs=getConfigSetRoot(obj)

            src=obj.Source;
            if isa(src,obj.BaseConfigClassID)
                cs=src.getConfigSet;
                if isempty(cs)
                    cs=src;
                end
            else
                cs=[];
            end
        end

        function cs=getCS(obj)

            cs=obj.getConfigSetRoot;
            if isa(cs,'Simulink.ConfigSetRef')&&~isempty(cs.LocalConfigSet)
                cs=cs.LocalConfigSet;
            end
        end
    end

    methods(Access=public)

        update(obj,src,name)


        updateOverride(obj)


        value=getParamValue(obj,name,varargin)





        status=getFastParamStatus(obj,pdata,component,cs,componentStatusMap)




        status=getParamStatus(obj,name,varargin)


        pdata=getParamData(obj,name,varargin)



        list=getStatusDependsOn(obj,name,paramData)




        valueList=getWidgetStatusList(obj,pname,varargin);
        statusList=getWidgetValueList(obj,pname,varargin);
        wList=getWidgetDataList(obj,pname,varargin);

        w=getWidgetData(obj,wname);
        pName=widgetToParam(obj,wName,varargin);


        setParamValue(obj,name,val)


        ensureServiceOn(obj)


        out=isValidParam(obj,name)

        lock(obj)
        flag=isLocked(obj)
        flush(obj,refresh)



        out=getParamStruct(obj,data)
        out=getParamStructNoData(obj,name)


        out=getParamOwner(obj,name,varargin)


        out=getModelInfo(obj)
    end

    methods(Access=public)
        setupTLC(obj,cs)
        setupListener(obj,cs)
        setupRefListener(obj)

        setupHDL(obj,cs)
        refresh(obj)
        callback(obj,m,e)
        dialogCallback(obj,msg)
        newValue=errorCheck(obj,cs,pdata,value)

        addParamToRefresh(obj,param)
        attachView(obj);
        detachView(obj);
    end

    methods(Hidden=true)



        setup(obj)
        init(obj)
        resetAdapter(obj)






        status=getParamWidgetStatus(obj,name,varargin)



    end
end


