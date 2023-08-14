

function this=BlockAnnotation(blockH)

    narginchk(0,1);
    if nargin<1
        blockH=[];
    end

    this=pslink.BlockAnnotation;

    if~isa(blockH,'Simulink.Block')
        try
            blockH=get_param(blockH,'Object');
        catch Me %#ok<NASGU>
            blockH=[];
        end
    end

    if~isa(blockH,'Simulink.Block')
        blockH=[];
    else
        blkObject=get_param(bdroot(blockH.Handle()),'Object');
        if isa(blkObject,'handle.handle')
            this.listeners=handle.listener(...
            blkObject,'CloseEvent',@(srcObj,evt)i_close(this));
            this.listeners(2)=handle.listener(blkObject,'DeleteEvent',@(srcObj,evt)i_close(this));
        else
            this.listeners=listener(...
            blkObject,'CloseEvent',@(srcObj,evt)i_close(this));
            this.listeners(2)=listener(blkObject,'DeleteEvent',@(srcObj,evt)i_close(this));
        end
    end


    this.PSAnnotationType='Check';
    this.PSAnnotationKind=' ';
    this.PSClassification=' ';
    this.PSStatus=' ';
    this.PSComment='';
    this.PSOnlyOneCheck=true;
    this.Block=blockH;


    function i_close(this)

        delete(this.listeners);
        delete(this);


