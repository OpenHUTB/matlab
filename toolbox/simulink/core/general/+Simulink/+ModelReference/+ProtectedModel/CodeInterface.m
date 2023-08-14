




classdef CodeInterface<rtw.report.CodeInterface
    properties
        generateHTML=true;
        TunableParameters={};
    end
    methods
        function obj=CodeInterface(modelName,buildDir)
            obj=obj@rtw.report.CodeInterface(modelName,buildDir);
        end

        function out=getTitle(~)
            out=DAStudio.message('RTW:report:ProtectedModelInterfaceLink');
        end

        function generate(obj)
            if~obj.generateHTML
                return;
            else
                generate@rtw.report.CodeInterface(obj);
            end
        end

        function txt=emitHTML(obj)

            try

                codeDescriptor=coder.internal.getCodeDescriptorInternal(obj.BuildDir,obj.ModelName,247362);
                codeInfo=codeDescriptor.getFullCodeInfo();

                if isempty(codeInfo)||isempty(codeInfo.codeInfo)
                    DAStudio.error('RTW:report:ERTGRTSimOnly');
                end

                codeInfo=codeInfo.codeInfo;

                if isfield(codeInfo,'expInports')
                    expInports=codeInfo.expInports;
                else
                    expInports='';
                end


                codeInfo.Parameters=codeInfo.Parameters(...
                arrayfun(@(x)obj.isModelArgument(x)||obj.isAccessibleParameter(x),...
                codeInfo.Parameters));


                doc=coder.internal.codeinfo('getHTMLReport',codeInfo,expInports,false,obj.BuildDir,obj);
                doc.addHeadItem('<script language="JavaScript" type="text/javascript" src="rtwreport_utils.js"></script>');
                doc.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');
                doc.setBodyAttribute('ONLOAD',coder.internal.coderReport('getOnloadJS','rtwIdCodeInterface'));
                txt=doc.emitHTML();
            catch e
                txt=obj.generateErrorReportPage(e);
            end
        end

        function out=getRelevantType(obj,portData)
            creator=Simulink.ModelReference.ProtectedModel.getCreatorDuringProtection(obj.ModelName);
            if strcmp(creator.currentMode,'SIM')
                out=portData.Type;
            else
                out=getRelevantType@rtw.report.CodeInterface(obj,portData);
            end
        end

        function out=hasEntryPointFcns(obj)
            creator=Simulink.ModelReference.ProtectedModel.getCreatorDuringProtection(obj.ModelName);
            if strcmp(creator.currentMode,'SIM')
                out=false;
            else
                out=true;
            end
        end

        function out=generateErrorReportPage(obj,exception)
            title=DAStudio.message('RTW:report:CodeInterfaceErrorTitle',obj.ModelName);
            msg=obj.getErrorMessage(exception);
            bodyOption=['ONLOAD="',coder.internal.coderReport('getOnloadJS','rtwIdCodeInterface'),'"'];

            out=coder.report.ReportPageBase.getDefaultErrorHTML(title,msg,bodyOption);
        end

        function out=getErrorMessage(~,exception)

            out=[DAStudio.message('RTW:report:CodeInterfaceInternalError'),'<br>',exception.message];
        end

        function txt=getEntryFcnTitle(obj)



            tgt=get_param(obj.ModelName,'SystemTargetFile');
            [~,tgt]=fileparts(tgt);
            txt=DAStudio.message('RTW:codeInfo:protectedMdlReportEntryPointFunctions',upper(tgt));
        end

        function out=isModelArgument(obj,param)

            out=strcmp(param.SID,obj.ModelName);
        end

        function out=isAccessibleParameter(obj,param)


            out=isempty(param.SID)&&any(strcmp(param.GraphicalName,obj.TunableParameters));
        end
    end
end


