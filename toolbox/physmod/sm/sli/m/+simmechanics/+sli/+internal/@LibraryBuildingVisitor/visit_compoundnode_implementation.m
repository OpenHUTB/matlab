function visit_compoundnode_implementation(thisVisitor,aCompoundNode)






    if isa(aCompoundNode.Info,'simmechanics.sli.internal.LibInfo')
        parentNode=aCompoundNode.Parent;
        if isempty(parentNode)


            libInfo=aCompoundNode.Info;
            close_system(libInfo.LibFileName,0);

            modelH=new_system(libInfo.LibFileName,'library');
            thisVisitor.SLHandle(aCompoundNode.NodeID)=modelH;

            libLoc=[20,20,420,220];

            set_param(modelH,'Location',libLoc);


            vInfo=ver('mech');
            defaultFontName='Helvetica';
            set_param(modelH,'ModelVersionFormat',...
            [vInfo.Version,'%<AutoIncrement: 0 >'],...
            'DefaultBlockFontName',defaultFontName,...
            'DefaultAnnotationFontName',defaultFontName,...
            'DefaultLineFontName',defaultFontName);


            annotation=libInfo.Annotation;
            if~isempty(annotation)

                add_block('built-in/Note',[libInfo.LibFileName,'/',annotation],...
                'FontWeight','bold','FontName','auto','FontSize','-1',...
                'HorizontalAlignment','center','Position',[40,40]);
            end

        else
            libInfo=aCompoundNode.Info;
            if strcmp(libInfo.Hidden,'on')
                return;
            end

            hParent=thisVisitor.SLHandle(aCompoundNode.Parent.NodeID);


            subsysH=add_block('built-in/SubSystem',[getfullname(hParent),'/',...
            libInfo.SLBlockProperties.Name]);
            thisVisitor.SLHandle(aCompoundNode.NodeID)=subsysH;

            slProps=properties(libInfo.SLBlockProperties);
            for idx=1:length(slProps)
                set_param(subsysH,slProps{idx},...
                libInfo.SLBlockProperties.(slProps{idx}));
            end


            set_param(subsysH,'Mask',libInfo.SLBlockProperties.Mask);



            icon=simmechanics.Icon;
            pos=libInfo.SLBlockProperties.Position;
            icon.Size=[pos(3)-pos(1),pos(4)-pos(2)];

            if strcmp(libInfo.ShowIcon,'on')&&~isempty(libInfo.IconFile)
                icon.setImage(libInfo.IconFile);
            elseif strcmp(libInfo.ShowIcon,'on')&&~isempty(libInfo.DVGIconKey)
                icon.ShowName=true;
            else


                if isempty(libInfo.SLBlockProperties.MaskDisplay)

                    libInfo.SLBlockProperties.MaskDisplay=libInfo.SLBlockProperties.Name;
                end
                icon.setText(libInfo.SLBlockProperties.MaskDisplay);
            end
            icon.ShowFrame=...
            strcmpi(libInfo.SLBlockProperties.MaskIconFrame,'on');
            icon.setupIcon(subsysH);


            maskParams=libInfo.MaskParameters;

            if(strcmpi(get_param(subsysH,'Mask'),'on'))
                maskObj=Simulink.Mask.get(subsysH);
            else
                maskObj=Simulink.Mask.create(subsysH);
            end

            maskObj.Type=libInfo.SLBlockProperties.Name;


            if~isempty(libInfo.DVGIconKey)
                maskObj.BlockDVGIcon=libInfo.DVGIconKey;
            end

            for mIdx=1:length(maskParams)
                if strcmpi(maskParams(mIdx).ReadOnly,'on')
                    maskObj.addParameter(...
                    'Type',maskParams(mIdx).Type,...
                    'Prompt',maskParams(mIdx).Prompt,...
                    'Name',maskParams(mIdx).VarName,...
                    'Value',maskParams(mIdx).Value,...
                    'Evaluate',maskParams(mIdx).Evaluate,...
                    'Tunable',maskParams(mIdx).Tunable,...
                    'Visible',maskParams(mIdx).Visible,...
                    'Hidden',maskParams(mIdx).Hidden,...
                    'ReadOnly',maskParams(mIdx).ReadOnly,...
                    'TypeOptions',maskParams(mIdx).PopupChoices);
                else
                    maskObj.addParameter(...
                    'Type',maskParams(mIdx).Type,...
                    'Prompt',maskParams(mIdx).Prompt,...
                    'Name',maskParams(mIdx).VarName,...
                    'Value',maskParams(mIdx).Value,...
                    'Evaluate',maskParams(mIdx).Evaluate,...
                    'Tunable',maskParams(mIdx).Tunable,...
                    'Enabled',maskParams(mIdx).Enable,...
                    'Visible',maskParams(mIdx).Visible,...
                    'Hidden',maskParams(mIdx).Hidden,...
                    'ReadOnly',maskParams(mIdx).ReadOnly,...
                    'TypeOptions',maskParams(mIdx).PopupChoices);
                end
            end


            annotation=libInfo.Annotation;
            if~isempty(annotation)

                add_block('built-in/Note',[getfullname(subsysH),'/',annotation],...
                'FontWeight','bold','FontName','auto','FontSize','-1',...
                'HorizontalAlignment','center','Position',[40,40]);
            end

            n=length(aCompoundNode.Info.ForwardingTableEntries);
            if n>0
                thisVisitor.ForwardingTableEntries(end+1:end+n)=...
                aCompoundNode.Info.ForwardingTableEntries;
            end
        end
    end
end
