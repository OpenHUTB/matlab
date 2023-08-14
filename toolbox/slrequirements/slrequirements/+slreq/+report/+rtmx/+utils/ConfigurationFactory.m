classdef ConfigurationFactory<handle
    methods(Static)
        function out=getConfiguration(configurationData,preSetConfig)
            switch configurationData.Domain
            case 'slreq'
                out=slreq.report.rtmx.utils.ConfigurationForSLReq(configurationData);

            case 'simulink'
                out=slreq.report.rtmx.utils.ConfigurationForSLModel(configurationData);
            case 'link'
                out=slreq.report.rtmx.utils.ConfigurationForLink(configurationData);
            case 'highlight'
                out=slreq.report.rtmx.utils.ConfigurationForHighlighting(configurationData);
            case 'matrix'
                out=slreq.report.rtmx.utils.ConfigurationForMatrix(configurationData);

            case 'matlabcode'
                out=slreq.report.rtmx.utils.ConfigurationForMATLABCode(configurationData);
            case 'sldd'
                out=slreq.report.rtmx.utils.ConfigurationForSLDD(configurationData);
            case 'sltest'
                out=slreq.report.rtmx.utils.ConfigurationForSLTest(configurationData);

            otherwise
            end
            out.ArtifactID=configurationData.ArtifactID;
            setConfig(out,preSetConfig);
        end
    end
end

function setConfig(out,preSetConfig)
    for pindex=1:length(preSetConfig)
        cPreConfig=preSetConfig(pindex);
        disp(['search for ',cPreConfig.Name,'--',cPreConfig.Prop]);
        for cIndex=1:length(out.ConfigList)
            cConfig=out.ConfigList{cIndex};
            findprop=false;
            if strcmp(cConfig.ConfigName,cPreConfig.Name)

                for propIndex=1:length(cConfig.PropList)
                    cProp=cConfig.PropList{propIndex};

                    if strcmp(cProp.PropName,cPreConfig.Prop)&&strcmp(cProp.QueryName,cPreConfig.QueryName)
                        out.ConfigList{cIndex}.PropList{propIndex}.PropValue=true;
                        findprop=true;
                        break;
                    end
                end
            end
            if findprop
                disp(['findprop for ',cPreConfig.Name,'--',cPreConfig.Prop]);
                break;
            end
        end

    end
end