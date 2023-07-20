classdef TranslateView<Simulink.packagedmodel.inspect.QueryView




    methods(Access=public)
        function this=TranslateView(slxcFile)
            this=this@Simulink.packagedmodel.inspect.QueryView(slxcFile);
            this.MyPkgFile=slxcFile;
            this.MyData=table();
            this.MyModelName='';
        end
    end

    methods(Access=protected)
        function result=getTableRow(this,release,platform,aField,fieldName)
            isExtractable=this.isRowExtractable(release,platform);
            model=string(this.MyModelName);
            if strcmp(fieldName,'CODER')
                result={};
                for j=1:length(aField)
                    elem=aField(j);
                    coderData=strjoin([string(elem.targetSuffix),elem.context,elem.folderConfig]," | ");
                    anArr.targetSuffix=elem.arr.targetSuffix;
                    anArr.STFName=elem.arr.STFName;
                    anArr.genCodeOnly=elem.arr.genCodeOnly;
                    anArr.mode=elem.arr.mode;
                    anArr.checksum=elem.arr.checksum;
                    anArr.folderConfig=elem.arr.folderConfig;
                    anArr.targetMapKey=elem.arr.targetMapKey;
                    result=[result;{model,release,platform,coderData,...
                    anArr,isExtractable}];%#ok<AGROW>
                end
            else
                result={model,release,platform,string(aField),{slcache.Modes.(fieldName)},isExtractable};
            end
        end

        function result=getTableColumnNames(~)
            result={'Model','Release','Platform','Target','Data','IsExtractable'};
        end
    end

    methods(Access=private)


        function result=isRowExtractable(~,release,platform)
            currentRelease=Simulink.packagedmodel.getRelease();
            currentPlatform=Simulink.packagedmodel.getPlatform(false);
            allPlatform=Simulink.packagedmodel.getPlatform(true);
            result=(strcmp(release,currentRelease)&&...
            any(strcmp(platform,{currentPlatform,allPlatform})));
        end
    end

end
