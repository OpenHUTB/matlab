function visualizeConditionProp(infoFilePath)






    info=load(infoFilePath);
    orderedStateInfo=info.variantCondtionsForBlocks;


    [styler,stylerClass]=createStyler;


    fullPath=strsplit(orderedStateInfo(1).CurrentBlock,'/');
    open_system(fullPath{1});



    pauseTime=2;
    offset=10;

















    for orderIdx=1:size(orderedStateInfo,2)
        annotationList={};



        styler.applyClass(orderedStateInfo(orderIdx).CurrentBlock,stylerClass.curBlk);
        styler.applyClass(orderedStateInfo(orderIdx).SourceBlock,stylerClass.srcBlk);



        annotText=getAnnotationText(orderedStateInfo(orderIdx).CurrentBlock,orderedStateInfo(orderIdx).VVCE,...
        orderedStateInfo(orderIdx).CurrentBlockPortNumber,orderedStateInfo(orderIdx).CurrentBlockBranchID);

        note=Simulink.Annotation(annotText);
        blkPosition=get_param(orderedStateInfo(orderIdx).CurrentBlock,'Position');
        note.Position=[blkPosition(1),blkPosition(4)+offset];
        annotationList{end+1}=note;

        annotText=getAnnotationText(orderedStateInfo(orderIdx).SourceBlock,orderedStateInfo(orderIdx).srcVVCE,...
        orderedStateInfo(orderIdx).SourceBlockPortNumber,orderedStateInfo(orderIdx).SourceBlockBranchID);

        note=Simulink.Annotation(annotText);
        blkPosition=get_param(orderedStateInfo(orderIdx).SourceBlock,'Position');
        note.Position=[blkPosition(1),blkPosition(4)+offset];
        annotationList{end+1}=note;


        pause(pauseTime);

        styler.removeClass(orderedStateInfo(orderIdx).CurrentBlock,stylerClass.curBlk);
        styler.removeClass(orderedStateInfo(orderIdx).SourceBlock,stylerClass.srcBlk);
        cellfun(@delete,annotationList);

        pause(pauseTime/2);


    end

    styler.destroy();
end

function annotText=getAnnotationText(blkPath,condition,portNum,branchId)
    delim='/';
    blkPath=strsplit(blkPath,delim);
    annotText=[blkPath{1},delim,' : ',num2str(portNum),' : ',num2str(branchId),' : ',condition];
end

function[styler,stylerClass]=createStyler
    stylerClass.curBlk='currentBlock';
    stylerClass.srcBlk='SourceBlock';

    styler=diagram.style.getStyler('VariantConditionDebugStyle');

    if(isempty(styler))

        diagram.style.createStyler('VariantConditionDebugStyle');
        styler=diagram.style.getStyler('VariantConditionDebugStyle');
    end

    curBlkHighlight=diagram.style.Style;
    curBlkHighlight.set('FillStyle','Solid');
    curBlkHighlight.set('FillColor',[1.0,0.7,0.0,1.0]);
    curBlkHighlight.set('StrokeColor',[1.0,0.0,0.0,1.0]);
    curBlkHighlight.set('StrokeWidth',1.0);
    curBlkHighlight.set('StrokeStyle','SolidLine');

    styler.addRule(curBlkHighlight,diagram.style.ClassSelector('currentBlock'));

    srcBlkHighlight=diagram.style.Style;
    srcBlkHighlight.set('FillStyle','Solid');
    srcBlkHighlight.set('FillColor',[0.0,0.7,1.0,1.0]);
    srcBlkHighlight.set('StrokeColor',[1.0,0.0,0.0,1.0]);
    srcBlkHighlight.set('StrokeWidth',1.0);
    srcBlkHighlight.set('StrokeStyle','SolidLine');

    styler.addRule(srcBlkHighlight,diagram.style.ClassSelector('SourceBlock'));

end















