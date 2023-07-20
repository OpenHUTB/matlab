


classdef Utilities

    methods(Access=public,Static)

        function sfObject=getStateflowObjectFromSid(sid)
            handle=Simulink.ID.getHandle(sid);
            if isa(handle,'double')
                chartId=sfprivate('block2chart',handle);
                sfObject=idToHandle(sfroot,chartId);
            else
                sfObject=handle;
            end
        end

        function blockType=getBlockTypeFromBlockPath(blockPath)
            sfBlockType=get_param(blockPath,'SFBlockType');
            switch sfBlockType
            case 'MATLAB Function'
                blockType=CsEml.BlockType.MATLABFunction;
            case 'Chart'
                blockType=CsEml.BlockType.Chart;
            case 'State Transition Table'
                blockType=CsEml.BlockType.StateTransitionTable;
            case 'Truth Table'
                blockType=CsEml.BlockType.TruthTable;
            otherwise
                blockType=CsEml.BlockType.Invalid;
            end
        end

        function inferfenceReport=getInferenceReportFromBlockPath(blockPath)

            if isstring(blockPath)
                blockChar=char(blockPath);
            else
                blockChar=blockPath;
            end

            stateflowId=sfprivate('block2chart',blockChar);
            blockHandle=get_param(blockChar,'Handle');




            blockCheckSum=sf('SFunctionSpecialization',stateflowId,blockHandle,true);
            if isempty(blockCheckSum)
                inferfenceReport=[];
                return;
            end

            [~,irFile,~,~]=sfprivate('get_report_path',pwd,blockCheckSum,false);
            if~exist(irFile,'file')


                chartH=idToHandle(sfroot(),stateflowId);
                modeldir=fileparts(chartH.Machine.FullFileName);
                reportDir=fullfile(sfprivate('get_sf_proj',modeldir),'EMLReport');
                irFile=fullfile(reportDir,[blockCheckSum,'.mat']);
            end

            if exist(irFile,'file')
                report=load(irFile);
                inferfenceReport=report.report.inference;
            else
                inferfenceReport=[];
            end

















        end

        function hyperLink=getHyperLinkFromFile(filePath,startIndex,endIndex)
            if isstring(filePath)
                charPath=char(filePath);
            else
                charPath=filePath;
            end

            [~,fileName,fileExt]=fileparts(charPath);
            charPath=[fileName,fileExt];

            cellPath=modeladvisorprivate('HTMLjsencode',charPath,'encode');
            path=cellPath{1};
            cmd='matlab: modeladvisorprivate hiliteFile ';
            if nargin==1
                hyperLink=sprintf('%s %s',cmd,path);
            else
                hyperLink=sprintf('%s %s:%d-%d',cmd,path,startIndex,endIndex);
            end
        end

        function hyperLink=getHyperLinkFromSid(sid,startIndex,endIndex)
            if isstring(sid)
                charSid=char(sid);
            else
                charSid=sid;
            end
            cmd='matlab: modeladvisorprivate hiliteSystem USE_SID';
            if nargin==1
                hyperLink=sprintf('%s:%s',cmd,charSid);
            else
                hyperLink=sprintf('%s:%s:%d-%d',cmd,charSid,startIndex,endIndex);
            end
        end

        function blockList=getBlockListFromModel(modelName)
            followLinks='on';
            lookUnderMasks='all';
            sfBlockTypeTable={...
            'MATLAB Function';...
            'Chart'};


            cellList=cell(0,1);
            for i=1:numel(sfBlockTypeTable)
                sfBlockType=sfBlockTypeTable{i};


                findings=find_system(modelName,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks',followLinks,...
                'LookUnderMasks',lookUnderMasks,...
                'Type','block',...
                'BlockType','SubSystem',...
                'SFBlockType',sfBlockType);
                cellList=[cellList;findings];%#ok<AGROW>
            end
            blockList=string(cellList);
        end

        function html=createCodeFragment(code,class,link)
            htmlSpan=Advisor.Element('span','class',class);
            if isstring(code)
                htmlSpan.setContent(char(code));
            else
                htmlSpan.setContent(code);
            end

            if nargin==3
                if isstring(link)
                    htmlA=Advisor.Element('a','href',char(link));
                else
                    htmlA=Advisor.Element('a','href',link);
                end
                htmlA.setContent(htmlSpan);
                advisorElement=htmlA;
            else
                advisorElement=htmlSpan;
            end
            html=strrep(advisorElement.emitHTML(),newline,'');
        end

    end

end

