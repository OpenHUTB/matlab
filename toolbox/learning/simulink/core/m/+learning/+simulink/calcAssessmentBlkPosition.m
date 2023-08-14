

function blockPos=calcAssessmentBlkPosition(mdl,lastBlockPos,doOffset,assessmentType)

    if strcmp(assessmentType,'mlmodel')||strcmp(assessmentType,'sfmodel')
        blockH=30;
        blockW=45;
    else
        blockH=60;
        blockW=45;
    end

    if strcmp(assessmentType,'mlmodel')||strcmp(assessmentType,'sfmodel')
        blockPos=getModelAssessmentPositioning(mdl,blockW,blockH);
        return
    end



    if~isempty(lastBlockPos)
        blockPos=lastBlockPos;
        if doOffset
            blockPos=[blockPos(1),blockPos(2)+2*blockH,blockPos(3),blockPos(4)+2*blockH];
        end
    else
        blockPos=getEmptyModelPositioning(mdl,blockW,blockH);
    end


    function newPosition=getEmptyModelPositioning(model,blockWidth,blockHeight)




        editor=GLUE2.Util.findAllEditors(model);
        canvas=editor.getCanvas;

        canvasExtents=canvas.SceneRectInView;



        botright_corner=[canvasExtents(3)+canvasExtents(1)-.1*canvasExtents(3),...
        .5*(canvasExtents(4)+blockHeight)+canvasExtents(2)];
        upleft_corner=botright_corner-[blockWidth,blockHeight];

        newPosition=[upleft_corner,botright_corner];
    end

    function newPosition=getModelAssessmentPositioning(mdl,blockWidth,blockHeight)

        editor=GLUE2.Util.findAllEditors(mdl);
        canvas=editor.getCanvas;

        canvasExtents=canvas.SceneRectInView;

        botright_corner=[canvasExtents(3)+canvasExtents(1)-.1*canvasExtents(3),...
        blockHeight*4+canvasExtents(2)];

        upleft_corner=botright_corner-[blockWidth,blockHeight];

        newPosition=[upleft_corner,botright_corner];
    end

end
