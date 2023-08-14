classdef QueryView<Simulink.packagedmodel.inspect.ContentInspector




    methods(Access=public)
        function this=QueryView(slxcFile)
            this=this@Simulink.packagedmodel.inspect.ContentInspector();
            this.MyPkgFile=slxcFile;
            this.MyData=table();
            this.MyModelName='';
        end
    end

    methods(Access=protected)
        function validationChecks(~)


        end

        function initializeRelease(~,~)
        end

        function result=getTableRow(this,release,platform,aField,fieldName)
            model=string(this.MyModelName);
            if strcmp(fieldName,'CODER')
                result={};
                for j=1:length(aField)
                    elem=aField(j);
                    coderData=strjoin([string(elem.targetSuffix)...
                    ,elem.context,elem.folderConfig]," | ");
                    result=[result;...
                    {model,release,platform,coderData}];%#ok<AGROW>
                end
            else
                result={model,release,platform,string(aField)};
            end
        end

        function result=getTableColumnNames(~)
            result={'Model','Release','Platform','Target'};
        end

        function storeStruct(this,release,platform,aStruct)
            release=string(release);
            platform=string(platform);
            names=fieldnames(aStruct);
            rows={};
            for i=1:length(names)
                aField=aStruct.(names{i});
                if isempty(aField)
                    continue;
                end
                rows=[rows;this.getTableRow(release,platform,aField,names{i})];%#ok<AGROW>
            end
            this.MyData=[this.MyData;rows];
            this.MyData.Properties.VariableNames=this.getTableColumnNames();
        end

        function result=constructSimTargetText(~,~,~)
            result=string(DAStudio.message('Simulink:cache:reportSupportsSimTarget'));
        end

        function result=constructRapidTargetText(~,~,~)
            result=DAStudio.message('Simulink:cache:reportSupportsRapidAccel');
        end

        function result=constructAccelTargetText(~,~,~)
            result=DAStudio.message('Simulink:cache:reportSupportsAccel');
        end

        function result=constructVarCacheText(~,~,~)
            result=DAStudio.message('Simulink:cache:reportSupportsVarCache');
        end

        function result=constructWebViewText(~,~,~)
            result=DAStudio.message('Simulink:cache:reportSupportsWebView');
        end

        function result=constructSLDVText(~,~,~,mode)
            switch(mode)
            case 'SLDV_TG'
                msgID='Simulink:cache:reportSupportsTestGeneration';
            case 'SLDV_PP'
                msgID='Simulink:cache:reportSupportsPropertyProving';
            case 'SLDV_DED'
                msgID='Simulink:cache:reportSupportsDesignErrorDetection';
            case 'SLDV_XIL_TG'
                msgID='Simulink:cache:reportSupportsSILTestGeneration';
            otherwise
                result='';
                return;
            end

            result=DAStudio.message(msgID);
        end
    end
end


