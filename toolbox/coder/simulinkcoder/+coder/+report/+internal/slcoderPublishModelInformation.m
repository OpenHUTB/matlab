




classdef slcoderPublishModelInformation<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
        sourceSys='';
    end
    methods
        function obj=slcoderPublishModelInformation(type,template,aReportInfo)
            obj=obj@mlreportgen.dom.DocumentPart(type,template);
            obj.reportInfo=aReportInfo;
            if isempty(obj.reportInfo.SourceSubsystem)
                obj.sourceSys=obj.reportInfo.ModelName;
            else
                obj.sourceSys=obj.reportInfo.SourceSubsystem;
            end
            obj.sourceSys=Simulink.ID.getFullName(obj.sourceSys);
        end

        function fillModelSnapshot(obj)
            obj.addSubsystem(obj.sourceSys);
        end
        function fillSubsystemSnapshot(obj)
            import mlreportgen.dom.*;
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                subsys=find_system(obj.sourceSys,...
                'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.codeCompileVariants,...
                'FollowLinks','on',...
                'BlockType','SubSystem');
            else
                subsys=find_system(obj.sourceSys,...
                'LookUnderMasks','all',...
                'Variants','ActivePlusCodeVariants',...
                'FollowLinks','on',...
                'BlockType','SubSystem');
            end
            for i=1:length(subsys)
                try
                    obj.addSubsystem(subsys{i},i);
                catch

                end
            end
            if isempty(subsys)
                obj.append(Paragraph(DAStudio.message('RTW:report:NoSubsystem')));
            end
        end
        function fillModelReference(obj)
            import mlreportgen.dom.*;


            [~,mdl_blocks]=find_mdlrefs(obj.sourceSys,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);
            if~isempty(mdl_blocks)
                col1=[DAStudio.message('RTW:report:BlockName');mdl_blocks];
                col2=[DAStudio.message('RTW:report:ReferenceModelName');...
                get_param(mdl_blocks,'ModelName')];
                obj.append(Table([col1,col2],'TableStyleAltRow'));
            else
                obj.append(Paragraph(DAStudio.message('RTW:report:NoReferenceModel')));
            end
        end
        function addSubsystem(obj,sys,varargin)
            import mlreportgen.dom.*;
            id='';
            if nargin>2
                id=varargin{1};
            end
            import mlreportgen.dom.*
            p=Paragraph;
            if~isempty(id)
                p.append(sprintf('%d. ',id));
            end
            title=Text([DAStudio.message('RTW:report:SystemName'),' ',sys]);
            title.Style={Bold(),Underline()};
            p.append(title);
            obj.append(p);
            snap=SLPrint.Snapshot();
            snap.Target=sys;
            snap.FileName=tempname;
            snap.snap();
            filename=[snap.FileName,'.',lower(snap.Format)];
            image=Image(filename);
            ppi=get(0,'ScreenPixelsPerInch');

            max_width=ppi*6;
            max_height=ppi*8;
            pInfo=imfinfo(filename);
            w_factor=pInfo.Width/max_width;
            h_factor=pInfo.Height/max_height;
            max_factor=max(w_factor,h_factor);
            if max_factor>1
                image.Width=sprintf('%.2f',pInfo.Width/max_factor);
                image.Height=sprintf('%.2f',pInfo.Height/max_factor);
            end
            obj.append(image);
            obj.append(Paragraph(''));
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                blocks=find_system(sys,'SearchDepth',1,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.codeCompileVariants,...
                'FollowLinks','on');
            else
                blocks=find_system(sys,'SearchDepth',1,'LookUnderMasks','all',...
                'Variants','ActivePlusCodeVariants',...
                'FollowLinks','on');
            end
            blocks=blocks(2:end);
            blockNames=strrep(strrep(blocks,[sys,'/'],''),'//','/');
            if numel(blocks)>0
                obj.append(Paragraph(DAStudio.message('RTW:report:BlockInSystem')));
                blockTypes=get_param(blocks,'blocktype');
                aTable=Table([[DAStudio.message('RTW:report:BlockName');blockNames],...
                [DAStudio.message('RTW:report:BlockType');blockTypes]]);
                aTable.StyleName='TableStyleAltRow';
                obj.append(aTable);
                obj.append(Paragraph);
            else
                obj.append(Paragraph([sprintf('\t'),DAStudio.message('RTW:report:NoBlockInSystem')]));
            end
        end
    end
end


