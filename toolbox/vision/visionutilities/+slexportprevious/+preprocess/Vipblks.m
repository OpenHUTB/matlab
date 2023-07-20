function Vipblks(obj)




    if isR2021aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('visionanalysis/Deep Learning Object Detector');
    end

    if isR2015bOrEarlier(obj.ver)
        vvBlks=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'BlockType','VideoViewer');

        if~isempty(vvBlks)


            lib_mdl=getTempLib(obj);
            libBlock=[lib_mdl,'/',obj.generateTempName];




            add_block('built-in/S-Function',libBlock);


            set_param(libBlock,...
            'Mask','on',...
            'Parameters','inputType,useColorMap,colormapValue,specRange,minInputVal,maxInputVal,FigPos,AxisZoom,trueSizedOnce,OpenAtMdlStart,imagePorts,DefaultConfigurationName',...
            'MaskVariables','inputType=@1;useColorMap=@2;colormapValue=@3;specRange=@4;minInputVal=@5;maxInputVal=@6;FigPos=@7;AxisZoom=@8;trueSizedOnce=@9;OpenAtMdlStart=@10;imagePorts=@11;DefaultConfigurationName=@12;',...
            'MaskType','Video Viewer');

            pmask=Simulink.Mask.get(libBlock);
            y=pmask.getParameter('imagePorts');
            y.Evaluate='off';


            save_system(lib_mdl);



            sfuncBlock=libBlock;
            for i=1:length(vvBlks)
                blk=vvBlks{i};

                sid=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));
                obj.appendRule(getRuleChangeBlockType(sid,'VideoViewer','Video Viewer'));

                scope=scopeextensions.ScopeBlock.getInstanceForCoreBlock(blk);




                params={'Orientation','Position','inputType','useColorMap','colormapValue','specRange','minInputVal','maxInputVal','FigPos','AxisZoom','trueSizedOnce','OpenAtMdlStart','imagePorts','DefaultConfigurationName'};
                paramValues=cell(size(params));
                for j=1:length(params)
                    paramValues{j}=get_param(blk,params{j});
                end



                ud=get_param(blk,'UserData');


                if isempty(ud)
                    ud=struct;
                end
                if~isempty(scope)
                    ud.Scope=scope;
                    scopeCfg=get_param(blk,'ScopeSpecificationObject');
                    ud.ScopeCfgName=class(scopeCfg);
                    set_param(blk,'ScopeSpecification',scopeCfg,'ScopeSpecificationObject',[],'DefaultConfigurationName',class(scopeCfg));
                    if~isempty(scopeCfg)
                        scope.pScopeCfg=copy(scopeCfg);
                    end
                    if~isempty(scope.ScopeCfg)
                        scope.ScopeCfg.SaveAsString=false;
                    end
                end





                sfuncUd=struct;
                sfuncUd.ScopeCfgName=ud.ScopeCfgName;
                sfuncUd.Scope=ud.Scope;
                ud.Scope=[];
                set_param(blk,'UserData',ud);



                ports=get_param(blk,'Ports');
                numInputPorts=num2str(ports(1));
                numOutputPorts=num2str(ports(2));



                delete_block(blk);



                add_block(sfuncBlock,blk,...
                'GraphicalNumInputPorts',numInputPorts,...
                'GraphicalNumOutputPorts',numOutputPorts);


                for j=1:length(params)
                    set_param(blk,params{j},paramValues{j});
                end




                set_param(blk,'LinkStatus','Inactive');
                sfuncUd.Scope.Block=get_param(blk,'Object');

                sfuncUd.Scope.AbortDelete=true;
                set_param(blk,'LinkStatus','Restore');
                sfuncUd.Scope.AbortDelete=false;


                set_param(blk,'UserData',sfuncUd,'UserDataPersistent','on');



                sid=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));
                obj.appendRule(getRuleRemovePair(sid,'DefaultConfigurationName'));

            end



            newRef=sfuncBlock;

            if isR2011aOrEarlier(obj.ver)
                oldRef='vipsnks/Video Viewer';
            else
                oldRef='visionsinks/Video Viewer';
            end
            obj.appendRule(['<Block<SourceBlock|"',newRef,'":repval "',oldRef,'">>']);

        end

    end

    if isR2014bOrEarlier(obj.ver)

        vision.internal.bypassObsoleteError(true);

        warpBlks=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'MaskType','vision.internal.blocks.Warp');
        parseWarpRules(warpBlks,obj);
        vision.internal.bypassObsoleteError(false);

    end

    if isR2014aOrEarlier(obj.ver)
        vvBlks=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'MaskType','Video Viewer');

        for indx=1:numel(vvBlks)
            scope=scopeextensions.ScopeBlock.getInstance(vvBlks{indx});
            scopeSpec=scope.ScopeCfg;
            if~isempty(scopeSpec)
                scopeSpec.SaveAsString=false;
                if~isempty(scopeSpec.CurrentConfiguration)
                    cc=scopeSpec.CurrentConfiguration.Children;
                    for jndx=1:numel(cc)
                        if isempty(cc(jndx).PropertySet)
                            cc(jndx).PropertySet=extmgr.PropertySet;
                        end
                    end
                end
            end
        end
    end

    if isR2013aOrEarlier(obj.ver)

        vvBlks=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'MaskType','Video Viewer');

        for indx=1:numel(vvBlks)
            scope=scopeextensions.ScopeBlock.getInstance(vvBlks{indx});
            oldConfig=scope.ScopeCfg.CurrentConfiguration;
            if~isempty(oldConfig)
                for jndx=1:numel(oldConfig.Children)
                    convertPropertySetToOldFormat(oldConfig.Children(jndx));
                end
            end
        end
    end

    if isR2012bOrEarlier(obj.ver)
        videoViewerBlocks=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'MaskType','Video Viewer');
        for jndx=1:length(videoViewerBlocks)
            scope=scopeextensions.ScopeBlock.getInstance(videoViewerBlocks{jndx});



            oldConfig=scope.ScopeCfg.CurrentConfiguration;
            if isa(oldConfig,'extmgr.ConfigurationSet')
                scope.ScopeCfg.CurrentConfiguration=convertToOldFormat(oldConfig);
            end
        end
    end

    if isR2012aOrEarlier(obj.ver)
        videoViewerBlocks=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'MaskType','Video Viewer');
        for indx=1:numel(videoViewerBlocks)
            ud=get_param(videoViewerBlocks{indx},'UserData');
            if isempty(ud)||~isfield(ud,'ScopeCfgName')
                ud.ScopeCfgName=get_param(videoViewerBlocks{indx},'DefaultConfigurationName');
                set_param(videoViewerBlocks{indx},'UserData',ud);
            end
        end
    end

    if isR2011aOrEarlier(obj.ver)

        coordBlock='Convert to M-by-2 1-based RC';
        blockProcessingBlock=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'dialogcontrollerargs',{'blockproc'});
        if~isempty(blockProcessingBlock)
            for i=1:length(blockProcessingBlock)
                blk=blockProcessingBlock{i};
                blkroot=[get_param(blk,'Parent'),'/',get_param(blk,'Name'),'/Block iterator'];
                if exists([blkroot,'/',coordBlock])
                    delete_line(blkroot,'Matrix Concatenate/1',[coordBlock,'/1']);
                    delete_line(blkroot,[coordBlock,'/1'],'Goto/1');
                    delete_block([blkroot,'/',coordBlock]);
                    add_line(blkroot,'Matrix Concatenate/1','Goto/1');
                else
                    continue;
                end
            end
        end


        resizeBlock=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'MaskType','Resize');

        if~isempty(resizeBlock)
            newRef='"visiongeotforms/Resize"';
            oldRef='"vipgeotforms/Resize"';

            obj.appendRule(['<Block<SourceBlock|',newRef,':repval ',oldRef,'>>']);
        end

    end



    if isR2010bOrEarlier(obj.ver)&&~isR2008bOrEarlier(obj.ver)
        videoViewerBlocks=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'MaskType','Video Viewer');

        for indx=1:numel(videoViewerBlocks)

            blk=videoViewerBlocks{indx};

            set_param(blk,'LinkStatus','Inactive');

            scopeextensions.ScopeBlock.saveAs(videoViewerBlocks{indx},obj.ver);



            set_param(blk,'LinkStatus','Restore');


        end
    end

    if isR2010aOrEarlier(obj.ver)


        blockProcessingBlock=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'dialogcontrollerargs',{'blockproc'});
        if~isempty(blockProcessingBlock)
            for i=1:length(blockProcessingBlock)
                blk=blockProcessingBlock{i};
                blkroot=[get_param(blk,'Parent'),'/',get_param(blk,'Name'),'/Block iterator'];
                subsys=[blkroot,'/sub-block process'];



                NumI=get_param(blk,'NumI');
                if exists([blkroot,'/Matrix Concatenate'])
                    delete_line(blkroot,'Input/2',['Matrix Concatenate/',int2str(1)]);
                    for j=2:eval(NumI)
                        delete_line(blkroot,['Input',int2str(j),'/2'],['Matrix Concatenate/',int2str(j)]);
                    end
                    delete_line(blkroot,'Matrix Concatenate/1','Goto/1');
                    delete_block([blkroot,'/Goto']);
                    delete_block([blkroot,'/Goto Tag Visibility']);
                    delete_block([blkroot,'/Matrix Concatenate']);
                end
                if exists([subsys,'/Block Location'])
                    delete_block([subsys,'/Block Location']);
                end


                initStr='errmsg = vipblkblockproc(gcbh, NumI, NumO, Blocksize, Overlapsize, Traverse); error(errmsg);';
                dispStr='disp(''Block\n Processing'');';
                set_param(blk,'MaskInitialization',initStr,'MaskDisplay',dispStr);
            end
        end


        iterationCountBlock=findBlocksInActiveChoiceOfVSS(obj.modelName,'LookUnderMasks','on',...
        'FunctionName','svipblockprociter');
        if~isempty(iterationCountBlock)
            for i=1:length(iterationCountBlock)
                blk=iterationCountBlock{i};


                blocksize=get_param(blk,'blksize');
                overlapsize=get_param(blk,'ovlpsize');

                set_param(blk,'blksize',[blocksize,'{1}'],'ovlpsize',[overlapsize,'{1}']);

                oldNumI=slResolve('NumI',blk);
                newNumI=1;


                allPorts=get_param(blk,'PortHandles');
                for j=oldNumI:-1:newNumI+1
                    delete_line(get(allPorts.Inport(j),'Line'));
                end
                set_param(blk,'NumI',int2str(newNumI));
            end
        end

    end


    if~isR2008bOrEarlier(obj.ver)


        Simulink.addBlockDiagramCallback(obj.modelName,...
        'PreDestroy','cleanVideoViewer',@(~,~)onModelClose(obj.modelName));
    end

    if isR2006b(obj.ver)

        blks_vip=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','vipsnks/Video Viewer','inputType','Obsolete7b');
        blks_vis=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','visionsinks/Video Viewer','inputType','Obsolete7b');
        blks=[blks_vip;blks_vis];
        for i=1:length(blks)
            figPosMask=str2num(get_param(blks{i},'FigPos'));%#ok<ST2NM>
            if~isempty(figPosMask)
                screenSizeMask=get(0,'screenSize');
                figPosMask(2)=screenSizeMask(4)-figPosMask(2)-1;
                set_param(blks{i},'FigPos',mat2str(figPosMask));
            end
            isOne=strcmp(get_param(blks{i},'imagePorts'),'One multidimensional signal');
            if isOne
                set_param(blks{i},'inputType','Intensity');
            else
                set_param(blks{i},'inputType','RGB');
            end
        end


        wvf_bh_vip=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','vipsnks/Write AVI File','inputType','Obsolete');
        tvd_bh_vip=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','vipsnks/To Video Display','inputType','Obsolete');
        wvf_bh_vis=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','visionsinks/Write AVI File','inputType','Obsolete');
        tvd_bh_vis=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','visionsinks/To Video Display','inputType','Obsolete');
        blks=[wvf_bh_vip;tvd_bh_vip;wvf_bh_vis;tvd_bh_vis];
        for i=1:length(blks)
            isOne=strcmp(get_param(blks{i},'imagePorts'),'One multidimensional signal');
            if isOne
                set_param(blks{i},'inputType','Intensity');
            else
                set_param(blks{i},'inputType','RGB');
            end
        end

        blks=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','viptextngfix/Insert Text','inputType','Obsolete');
        for i=1:length(blks)
            blkTag=get_param(blks{i},'tag');
            set_param(blks{i},'tag','vipblks_tmp_nd_forward_compat');

            isOne=strcmp(get_param(blks{i},'imagePorts'),'One multidimensional signal');
            if isOne
                set_param(blks{i},'inputType','Intensity');
                txtColFrmDlg=strcmp(get_param(blks{i},'getTextColorFrom'),'Specify via dialog');
                if(txtColFrmDlg)
                    set_param(blks{i},'getTextIntensityFrom','Specify via dialog');
                    set_param(blks{i},'textIntensity',get_param(blks{i},'textColor'));
                else
                    set_param(blks{i},'getTextIntensityFrom','Input port');
                end
            else
                set_param(blks{i},'inputType','RGB');
            end

            set_param(blks{i},'tag',blkTag);
        end


        blks=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','viptextngfix/Draw Shapes','inType','Obsolete');
        for i=1:length(blks)
            isOne=strcmp(get_param(blks{i},'imagePorts'),'One multidimensional signal');
            if isOne
                set_param(blks{i},'inType','Intensity');
                set_param(blks{i},'intensity',get_param(blks{i},'color'));
            else
                set_param(blks{i},'inType','RGB');
            end
        end


        blks=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','viptextngfix/Draw Markers','inType','Obsolete');
        for i=1:length(blks)
            isOne=strcmp(get_param(blks{i},'imagePorts'),'One multidimensional signal');
            if isOne
                set_param(blks{i},'inType','Intensity');
                set_param(blks{i},'intensity',get_param(blks{i},'color'));
            else
                set_param(blks{i},'inType','RGB');
            end
        end


        blks=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock',sprintf('vipgeotforms/Projective\nTransformation'),'inType','Obsolete');
        for i=1:length(blks)
            isOne=strcmp(get_param(blks{i},'imagePorts'),'One multidimensional signal');
            if isOne
                set_param(blks{i},'inType','Intensity');
            else
                set_param(blks{i},'inType','RGB');
            end
        end

        blks_vip=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock',sprintf('vipconversions/Color Space\n Conversion'),'conversion','Obsolete');
        blks_vis=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock',sprintf('visionconversions/Color Space\n Conversion'),'conversion','Obsolete');
        blks=[blks_vip;blks_vis];
        for i=1:length(blks)
            blkTag=get_param(blks{i},'tag');
            set_param(blks{i},'tag','vipblks_tmp_nd_forward_compat');

            puString=get_param(blks{i},'conversionActive');
            set_param(blks{i},'conversion',puString);

            set_param(blks{i},'tag',blkTag);
        end

        blks_vip=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','vipsrcs/Video From Workspace','finalout','Obsolete');
        blks_vis=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','visionsources/Video From Workspace','finalout','Obsolete');
        blks=[blks_vip;blks_vis];
        for i=1:length(blks)
            blkTag=get_param(blks{i},'tag');
            set_param(blks{i},'tag','vipblks_tmp_nd_forward_compat');

            puString=get_param(blks{i},'finaloutActive');
            set_param(blks{i},'finalout',puString);

            set_param(blks{i},'tag',blkTag);
        end

        blks_vip=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','vipconversions/Demosaic');
        blks_vis=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','visionconversions/Demosaic');
        blks=[blks_vip;blks_vis];
        for i=1:length(blks)
            if strcmp(get_param(blks{i},'algorithm'),'Obsolete')
                blkTag=get_param(blks{i},'tag');
                set_param(blks{i},'tag','vipblks_tmp_nd_forward_compat');

                puString=get_param(blks{i},'algorithmActive');
                set_param(blks{i},'algorithm',puString);

                set_param(blks{i},'tag',blkTag);
            end
        end

        ifw_bh_vip=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','vipsrcs/Image From Workspace','tag','vipblks_nd');
        iff_bh_vip=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','vipsrcs/Image From File','tag','vipblks_nd');
        ifw_bh_vis=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','visionsources/Image From Workspace','tag','vipblks_nd');
        iff_bh_vis=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','visionsources/Image From File','tag','vipblks_nd');
        blks=[ifw_bh_vip;iff_bh_vip;ifw_bh_vis;iff_bh_vis];
        for i=1:length(blks)
            set_param(blks{i},'tag','');
        end

    elseif isR2007a(obj.ver)

        blks_vip=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','vipsnks/Video Viewer','inputType','Obsolete7b');
        blks_vis=findBlocksInActiveChoiceOfVSS(obj.modelName,'ReferenceBlock','visionsinks/Video Viewer','inputType','Obsolete7b');
        blks=[blks_vip;blks_vis];
        for i=1:length(blks)
            figPosMask=str2num(get_param(blks{i},'FigPos'));%#ok<ST2NM>
            if~isempty(figPosMask)
                screenSizeMask=get(0,'screenSize');
                figPosMask(2)=screenSizeMask(4)-figPosMask(2)-1;
                set_param(blks{i},'FigPos',mat2str(figPosMask));
            end
            set_param(blks{i},'inputType','Obsolete');
        end
    end

end

function blks=findBlocksInActiveChoiceOfVSS(varargin)
    modelName=varargin{1};


    blks=find_system(modelName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    varargin{2:end});
end

function onModelClose(modelName)

    Simulink.removeBlockDiagramCallback(modelName,'PreDestroy','cleanVideoViewer');
    videoViewerBlocks=findBlocksInActiveChoiceOfVSS(modelName,'LookUnderMasks','on',...
    'MaskType','Video Viewer');

    for indx=1:numel(videoViewerBlocks)
        set_param(videoViewerBlocks{indx},'LinkStatus','Inactive');
        b=scopeextensions.ScopeBlock.getInstance(videoViewerBlocks{indx});
        delete(b);
        set_param(videoViewerBlocks{indx},'LinkStatus','Restore');
    end

end


function e=exists(blk)
    e=getSimulinkBlockHandle(blk)>=0;
end


function parseWarpRules(warpBlks,obj)

    for indx=1:numel(warpBlks)
        TransformMatrixSource=get_param(warpBlks{indx},'TransformMatrixSource');
        TransformMatrix=get_param(warpBlks{indx},'TransformMatrix');
        InterpolationMethod=get_param(warpBlks{indx},'InterpolationMethod');
        BackgroundFillValue=get_param(warpBlks{indx},'BackgroundFillValue');
        OutputImagePositionSource=get_param(warpBlks{indx},'OutputImagePositionSource');
        ROIInputPort=get_param(warpBlks{indx},'ROIInputPort');
        ROIValidityOutputPort=get_param(warpBlks{indx},'ROIValidityOutputPort');

        outputSize='[]';
        outputLoc='[]';

        if strcmpi(TransformMatrixSource,'Custom')
            TransformMatrixSource='Specify via dialog';
        end

        if strcmpi(OutputImagePositionSource,'Custom')
            OutputImagePositionSource='Specify via dialog';
        end

        if strcmpi(ROIInputPort,'on')
            ROIInputPort='Input port';
            roiMethod='Rectangle ROI';
        else
            ROIInputPort='Specify via dialog';
            roiMethod='Whole input image';
        end

        oldBlock=warpBlks{indx};
        name=get_param(oldBlock,'Name');
        parent=get_param(oldBlock,'Parent');
        tempBlock=[parent,'/temp',num2str(indx)];
        add_block('vipobslib/Apply Geometric Transformation',tempBlock);
        decorations=getDecorationParams(oldBlock);
        mask={};


        if strcmpi(get_param(oldBlock,'OutputImagePositionSource'),'Same as input image')

        else
            OutputImagePosition=get_param(oldBlock,'OutputImagePosition');





            OutputImagePositionStr=regexprep(OutputImagePosition,'^\[|\]([^\]]*)$','');

            OutputImagePositionCell=strsplit(OutputImagePositionStr,{' ',',',';'});
            OutputImagePositionCell=OutputImagePositionCell(~cellfun(@isempty,OutputImagePositionCell));

            if~isempty(OutputImagePositionCell)









                funcIdx=regexp(OutputImagePositionCell,'\w\(');

                if any(~cellfun(@isempty,funcIdx))


                    issueWarpWarning(obj,name,OutputImagePosition);
                    outputSize='[]';
                    outputLoc='[]';
                else
                    switch(numel(OutputImagePositionCell))
                    case 1

                        outputSize=['fliplr(',OutputImagePositionCell{:},'(3:4))'];

                        outputLoc=[OutputImagePositionCell{:},'(1:2)-1'];
                    case 2




                        outputSize=['fliplr(',OutputImagePositionCell{2},')'];
                        outputLoc=[OutputImagePositionCell{1},'-1'];

                    case 4
                        outputSize=['[',OutputImagePositionCell{4},',',OutputImagePositionCell{3},']'];
                        outputLoc=['[',OutputImagePositionCell{1},'-1',',',OutputImagePositionCell{2},'-1',']'];
                    otherwise
                        issueWarpWarning(obj,name,OutputImagePosition);
                        outputSize='[]';
                        outputLoc='[]';
                    end
                end
            end
        end

        try
            set_param(tempBlock,...
            'tformSource',TransformMatrixSource,...
            'tformValue',TransformMatrix,...
            'interpolationMethod',InterpolationMethod,...
            'viewPortMethod',OutputImagePositionSource,...
            'fillValue',BackgroundFillValue,...
            'roiMethod',roiMethod,...
            'roiSource',ROIInputPort,...
            'outputLoc',outputLoc,...
            'outputSize',outputSize,...
            'inputClipFlag',ROIValidityOutputPort);


            delete_block(oldBlock);
            add_block(tempBlock,[parent,'/',name],decorations{:},mask{:});
            delete_block(tempBlock);
        catch e

            obj.reportWarning(e.identifier,e.message);
        end

    end
end

function issueWarpWarning(obj,name,OutputImagePosition)
    obj.errorFcn(...
    MException('vision:obsolete:WarpOutputLocWarning',...
    sprintf('In %s block: %s',name,getString(message('vision:obsolete:WarpOutputLoc',...
    OutputImagePosition)))...
    ));
end

function decorations=getDecorationParams(block)





    decorations={
    'Position',[];
    'Orientation',[];
    'ForegroundColor',[];
    'BackgroundColor',[];
    'DropShadow',[];
    'NamePlacement',[];
    'FontName',[];
    'FontSize',[];
    'FontWeight',[];
    'FontAngle',[];
    'ShowName',[]
    };

    for i=1:size(decorations,1)
        decorations{i,2}=get_param(block,decorations{i,1});
    end

    decorations=reshape(decorations',1,length(decorations(:)));

end

function rule=getRuleChangeBlockType(sid,oldBlockType,newBlockType)
    rule=['<Block<SID|"',sid,'"><BlockType|"',oldBlockType,'":repval "'...
    ,newBlockType,'">>'];
end

function rule=getRuleRemovePair(sid,pairName)
    rule=['<Block<SID|"',sid,'">','<',pairName,':remove>>'];
end
