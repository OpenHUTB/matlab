





classdef CodeReplacements<coder.report.CodeReplacementsBase
    methods
        function obj=CodeReplacements(aTfl)
            obj=obj@coder.report.CodeReplacementsBase(aTfl);
        end
        function tr=getTargetRegistry(obj)
            if isempty(obj.TargetRegistry)
                obj.TargetRegistry=RTW.TargetRegistry.getInstance('coder');
            end
            tr=obj.TargetRegistry;
        end
        function out=getTitle(~)
            out=message('Coder:reportGen:ReplacementsTitle').getString;
        end
        function out=getShortTitle(~)
            out=message('Coder:reportGen:ReplacementsLink').getString;
        end
        function out=getDefaultReportFileName(~)
            out='replacements.html';
        end
        function out=getDisableMessage(~)
            out=message('Coder:reportGen:CodeReplacementReportDisabled').getString;
        end
        function out=getJavaScriptOnLoad(~)
            out=coder.internal.coderReport('getOnloadJS','rtwIdCodeReplacements').getString;
        end
        function title=getFunctionReplacmentTitle(~)
            title=message('Coder:reportGen:FunctionReplacementTitle').getString;
        end
        function title=getSimdReplacementTitle(~)
            title=message('Coder:reportGen:SimdReplacementTitle').getString;
        end
        function intro=getCodeReplacmentsIntro(~)
            intro=message('Coder:reportGen:CodeReplacementIntro').getString;
        end
        function intro=getAddReplacementIntro(~)
            intro=message('Coder:reportGen:AddReplacementIntro').getString;
        end
        function intro=getSubReplacementIntro(~)
            intro=message('Coder:reportGen:SubReplacementIntro').getString;
        end
        function intro=getMulReplacementIntro(~)
            intro=message('Coder:reportGen:MulReplacementIntro').getString;
        end
        function intro=getDivReplacementIntro(~)
            intro=message('Coder:reportGen:DivReplacementIntro').getString;
        end
        function intro=getCastReplacementIntro(~)
            intro=message('Coder:reportGen:CastReplacementIntro').getString;
        end
        function intro=getSLReplacementIntro(~)
            intro=message('Coder:reportGen:SLReplacementIntro').getString;
        end
        function intro=getSRReplacementIntro(~)
            intro=message('Coder:reportGen:SRReplacementIntro').getString;
        end
        function intro=getEMReplacementIntro(~)
            intro=message('Coder:reportGen:EMReplacementIntro').getString;
        end
        function intro=getTransReplacementIntro(~)
            intro=message('Coder:reportGen:TransReplacementIntro').getString;
        end
        function intro=getConjReplacementIntro(~)
            intro=message('Coder:reportGen:ConjReplacementIntro').getString;
        end
        function intro=getHermReplacementIntro(~)
            intro=message('Coder:reportGen:HermReplacementIntro').getString;
        end
        function intro=getTRReplacementIntro(~)
            intro=message('Coder:reportGen:TRReplacementIntro').getString;
        end
        function intro=getHMReplacementIntro(~)
            intro=message('Coder:reportGen:HMReplacementIntro').getString;
        end
        function intro=getGTReplacementIntro(~)
            intro=message('Coder:reportGen:GTReplacementIntro').getString;
        end
        function intro=getGTEReplacementIntro(~)
            intro=message('Coder:reportGen:GTEReplacementIntro').getString;
        end
        function intro=getLTReplacementIntro(~)
            intro=message('Coder:reportGen:LTReplacementIntro').getString;
        end
        function intro=getLTEReplacementIntro(~)
            intro=message('Coder:reportGen:LTEReplacementIntro').getString;
        end
        function intro=getEQReplacementIntro(~)
            intro=message('Coder:reportGen:EQReplacementIntro').getString;
        end
        function intro=getNEQReplacementIntro(~)
            intro=message('Coder:reportGen:NEQReplacementIntro').getString;
        end
        function intro=getSimdReplacementIntro(~)
            intro=message('Coder:reportGen:SimdReplacementIntro').getString;
        end
        function colHeader=getTableColumnHeader(~)
            colHeader=message('Coder:reportGen:RepTableColHeader').getString;
        end
        function execute(obj)


            [tflList,tflName]=obj.getLibraryContents;
            p=Advisor.Paragraph;

            if~isempty(tflList)
                contents=Advisor.Text(message(...
                'CoderFoundation:report:CodeReplacementLibraryList',tflName).getString);
                p.addItem(contents);
                p.addItem(tflList);
            else
                assert(isempty(tflName)||strcmpi(tflName,'None'));
                contents=Advisor.Text(message(...
                'CoderFoundation:report:CodeReplacementLibraryListNone').getString);
                p.addItem(contents);
            end
            obj.addItem(p);


            instructionSetString=obj.getInstructionSetString;
            if~isempty(instructionSetString)&&~isempty(instructionSetString.Items)
                p=Advisor.Paragraph;
                contents=Advisor.Text(message(...
                'CoderFoundation:report:InstructionSetExtensionsList').getString);
                p.addItem(contents);
                p.addItem(instructionSetString);

                obj.addItem(p);
            end

            cmd=['matlab: emlcprivate invokeViewerForReport ''',obj.LibName,''''];
            alink=obj.getMatlabCallHyperlink(cmd);
            p=Advisor.Paragraph;
            contents=Advisor.Text(message(...
            'CoderFoundation:report:CodeReplacementLibraryViewer',alink{1},alink{2}).getString);
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
                matlabInternalPath=matlabroot();


                if contains(htmlStr,matlabInternalPath)&&...
                    slsvTestingHook('ReportInternalHitLocationForML')<1

                    tmp=textscan(sid,'%s','Delimiter','\n');
                    traceTop=tmp{1}{end};
                    fileEndIdices=strfind(traceTop,':');
                    fileEndIdx=fileEndIdices(end);
                    if~isempty(fileEndIdx)&&fileEndIdx>1
                        fileEndIdx=fileEndIdx-1;
                        fullfileName=traceTop(1:fileEndIdx);
                        [~,internalFileName,ext]=fileparts(fullfileName);
                        htmlStr=DAStudio.message('CoderFoundation:report:CodeReplacementsInInternaFile',[internalFileName,ext]);
                    end
                end
            catch me %#ok<NASGU>
            end
        end
    end
end


