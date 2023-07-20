function[TunableParamStr,v]=getTunableParameter(slbh,value)




    v=[];
    TunableParamStr='';

    if~hdlgetparameter('GenDUTPortForTunableParam')
        return;
    end




    if ischar(value)
        [TunableParamStr,inNonTopDataDictionary,v]=evalTunableParam(slbh,value);



        if~strcmp(TunableParamStr,'')
            p=slbh;
            while(~isempty(p))
                q=get_param(p,'Object');
                if q.isMasked()
                    maskNames=get_param(p,'MaskNames');
                    if ismember(TunableParamStr,maskNames)
                        TunableParamStr='';
                        break;
                    end
                end
                p=get_param(p,'parent');
            end
        end




        if(~isempty(TunableParamStr)&&inNonTopDataDictionary)
            warning(message('hdlcoder:validate:TunableParamInNonTopDataDict',TunableParamStr));
        end
    end

    function[TunableParamStr,inNonTopDataDictionary,v]=evalTunableParam(slbh,value)
        TunableParamStr='';
        inNonTopDataDictionary=false;
        v=[];
        var=[];

        topLevelH=bdroot(slbh);
        topLevelName=get_param(topLevelH,'Name');
        needsCompile=strcmpi(get_param(topLevelH,'CompiledSinceLastChange'),'off');


        if needsCompile
            searchMethod='compiled';
        else
            searchMethod='precached';
        end

        hdlDriver=hdlcurrentdriver;
        [bExists,pVal]=hdlDriver.checkTunableParam(value);
        if bExists
            var=pVal;
        else
            try
                var=Simulink.findVars(topLevelName,'name',value,'searchmethod',searchMethod);
            catch
            end
            hdlDriver.cacheTunableParam(value,var);
        end

        if~isempty(var)&&(numel(var)==1)
            switch var.SourceType
            case 'data dictionary'
                dictionaryObj=Simulink.data.dictionary.open(var.Source);
                sectionObj=getSection(dictionaryObj,'Design Data');
                obj=evalin(sectionObj,value);
                if isa(obj,'Simulink.Parameter')&&strcmp(obj.CoderInfo.StorageClass,'ExportedGlobal')
                    TunableParamStr=value;
                    if all(size(obj.Value)>1)
                        v=hdlvalidatestruct(1,...
                        message('hdlcoder:validate:MatrixTunableParamUnsupported'));
                    end

                    hdlcoder=hdlcurrentdriver;
                    if~strcmp(topLevelName,hdlcoder.ModelName)
                        inNonTopDataDictionary=true;
                    end
                end
                close(dictionaryObj);
            case 'base workspace'
                obj=evalin('base',value);
                if isa(obj,'Simulink.Parameter')&&strcmp(obj.CoderInfo.StorageClass,'ExportedGlobal')
                    TunableParamStr=value;
                    if all(size(obj.Value)>1)
                        v=hdlvalidatestruct(1,...
                        message('hdlcoder:validate:MatrixTunableParamUnsupported'));
                    end
                end
            otherwise

            end
        end

