


classdef CodeReplacementMisses<coder.report.CodeReplacementsMissesBase
    properties
        ModelName='';
    end
    methods
        function obj=CodeReplacementMisses(modelName,aTfl)
            obj=obj@coder.report.CodeReplacementsMissesBase(aTfl);
            obj.ModelName=modelName;
        end
        function tr=getTargetRegistry(obj)
            if isempty(obj.TargetRegistry)
                obj.TargetRegistry=RTW.TargetRegistry.get;
            end
            tr=obj.TargetRegistry;
        end
        function out=getTitle(obj)
            out=DAStudio.message('RTW:report:CodeReplacementMissTitle',obj.ModelName);
        end
        function out=getShortTitle(~)
            out=DAStudio.message('RTW:report:CodeReplacementMissLink');
        end
        function out=getDefaultReportFileName(~)
            out='missed_replacements.html';
        end
        function out=getJavaScriptOnLoad(~)
            out=coder.internal.coderReport('getOnloadJS','rtwIdMissedCodeReplacements');
        end
        function title=getFunctionReplacmentTitle(obj)
            title=DAStudio.message('RTW:report:FunctionReplacementMissTitle',obj.ModelName);
        end
        function title=getSimdReplacmentTitle(obj)
            title=DAStudio.message('RTW:report:SimdReplacementMissTitle',obj.ModelName);
        end
        function intro=getCodeReplacmentsIntro(~)
            intro=DAStudio.message('RTW:report:CodeReplacementMissIntro');
        end
        function intro=getAddReplacementIntro(~)
            intro=DAStudio.message('RTW:report:AddMissReplacementIntro');
        end
        function intro=getSubReplacementIntro(~)
            intro=DAStudio.message('RTW:report:SubMissReplacementIntro');
        end
        function intro=getMulReplacementIntro(~)
            intro=DAStudio.message('RTW:report:MulMissReplacementIntro');
        end
        function intro=getDivReplacementIntro(~)
            intro=DAStudio.message('RTW:report:DivMissReplacementIntro');
        end
        function intro=getCastReplacementIntro(~)
            intro=DAStudio.message('RTW:report:CastMissReplacementIntro');
        end
        function intro=getSLReplacementIntro(~)
            intro=DAStudio.message('RTW:report:SLMissReplacementIntro');
        end
        function intro=getSRReplacementIntro(~)
            intro=DAStudio.message('RTW:report:SRMissReplacementIntro');
        end
        function intro=getEMReplacementIntro(~)
            intro=DAStudio.message('RTW:report:EMMissReplacementIntro');
        end
        function intro=getTransReplacementIntro(~)
            intro=DAStudio.message('RTW:report:TransMissReplacementIntro');
        end
        function intro=getConjReplacementIntro(~)
            intro=DAStudio.message('RTW:report:ConjMissReplacementIntro');
        end
        function intro=getHermReplacementIntro(~)
            intro=DAStudio.message('RTW:report:HermMissReplacementIntro');
        end
        function intro=getTRReplacementIntro(~)
            intro=DAStudio.message('RTW:report:TRMissReplacementIntro');
        end
        function intro=getHMReplacementIntro(~)
            intro=DAStudio.message('RTW:report:HMMissReplacementIntro');
        end
        function intro=getGTReplacementIntro(~)
            intro=DAStudio.message('RTW:report:GTMissReplacementIntro');
        end
        function intro=getGTEReplacementIntro(~)
            intro=DAStudio.message('RTW:report:GTEMissReplacementIntro');
        end
        function intro=getLTReplacementIntro(~)
            intro=DAStudio.message('RTW:report:LTMissReplacementIntro');
        end
        function intro=getLTEReplacementIntro(~)
            intro=DAStudio.message('RTW:report:LTEMissReplacementIntro');
        end
        function intro=getEQReplacementIntro(~)
            intro=DAStudio.message('RTW:report:EQMissReplacementIntro');
        end
        function intro=getNEQReplacementIntro(~)
            intro=DAStudio.message('RTW:report:NEQMissReplacementIntro');
        end
        function intro=getSimdReplacementIntro(~)
            intro=DAStudio.message('RTW:report:SimdMissReplacementIntro');
        end
        function colHeader=getTableColumnHeader1(~)
            colHeader=DAStudio.message('CoderFoundation:report:CodeReplacementMissColumn1');
        end
        function colHeader=getTableColumnHeader2(~)
            colHeader=DAStudio.message('CoderFoundation:report:CodeReplacementMissColumn2');
        end
        function colHeader=getTableColumnHeader3(~)
            colHeader=DAStudio.message('CoderFoundation:report:CodeReplacementMissColumn3');
        end
        function colHeader=getTableColumnHeader4(~)
            colHeader=DAStudio.message('CoderFoundation:report:CodeReplacementMissColumn4');
        end
        function alink=getHyperlinkForCrtoolHighlightEntry(obj,thisEnt)
            cmd=['matlab: coder.internal.invokeCrtoolHighlighEntry( ''',obj.ModelName,''', ''',thisEnt.UID,''')'];
            alink=Simulink.report.ReportInfo.getMatlabCallHyperlink(cmd);
        end

        function execute(obj)


            [tflList,tflName]=obj.getLibraryContents;
            p=ModelAdvisor.Paragraph;
            contents=ModelAdvisor.Text(DAStudio.message(...
            'CoderFoundation:report:CodeReplacementLibraryList',tflName));
            p.addItem(contents);
            if~isempty(tflList)
                p.addItem(tflList);
            end
            obj.addItem(p);


            instructionSetString=obj.getInstructionSetString;
            if~isempty(instructionSetString)&&~isempty(instructionSetString.Items)
                p=ModelAdvisor.Paragraph;
                contents=ModelAdvisor.Text(message(...
                'CoderFoundation:report:InstructionSetExtensionsList').getString);
                p.addItem(contents);
                p.addItem(instructionSetString);
                obj.addItem(p);
            end


            cmd=['matlab: rtwprivate invokeViewerForReport ''',obj.ModelName,''' ''',obj.LibName,''''];
            alink=Simulink.report.ReportInfo.getMatlabCallHyperlink(cmd);
            p=ModelAdvisor.Paragraph;
            contents=ModelAdvisor.Text(DAStudio.message(...
            'CoderFoundation:report:CodeReplacementLibraryViewer',alink{1},alink{2}));
            p.addItem(contents);
            obj.addItem(p);
            obj.addCodeReplacementSection;
        end
    end

    methods(Access=protected)

        function htmlStr=getSourcelocationFromSID(obj,sid)
            htmlStr=sid;
            try
                htmlStr=obj.getHyperlink(sid);
            catch me %#ok<NASGU>
            end
        end

    end

    methods(Static)

        function out=getDisableMessage(~)
            out=DAStudio.message('RTW:report:MissedCodeReplacementReportDisabled');
        end

    end

    methods

        function emit(obj,rpt,type,template)
            part=coder.report.internal.slcoderPublishCodeReplacements(type,template,obj);
            part.fill();
            rpt.append(part);
        end
        function fillCodeReplacementLibrary(obj,chapter)
            import mlreportgen.dom.*;
            [tflList,tflName]=obj.getRpggenLibraryContents;
            p=Paragraph(Text(obj.getMessage('CodeReplacementLibraryList',tflName)));
            chapter.append(p);
            if~isempty(tflList)
                for i=1:length(tflList)
                    chapter.append(tflList{i});
                end
            end
        end
        function fillCodeReplacementSections(obj,chapter)
            obj.addRptgenCodeReplacementSection(chapter);
        end
    end
end



