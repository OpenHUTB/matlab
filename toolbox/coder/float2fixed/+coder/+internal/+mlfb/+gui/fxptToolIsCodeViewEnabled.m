function enabled=fxptToolIsCodeViewEnabled(mode,strReturn)



    if~exist('mode','var')
        mode='global';
    end
    if~exist('strReturn','var')
        strReturn=false;
    end

    assert(ischar(mode)&&islogical(strReturn));
    setOutput(false);

    fpt=coder.internal.mlfb.FptFacade.getInstance();

    if~fpt.isLive()||~coder.internal.mlfb.gui.MlfbUtils.isCodeViewFeaturedOn()
        return;
    end

    try
        if fpt.isSudSet()&&hasFunctionBlocks()
            setOutput(true);

            switch mode
            case 'global'

            case 'tree'
                setOutput(isOverlapsSud(fpt.getSelectedTreeNode()));
            case 'table'
                setOutput(isListViewOverlapsSud());
            otherwise
                error('Unrecognized action context ''%s''',mode);
            end
        end
    catch err
        coder.internal.gui.asyncDebugPrint(err);
        setOutput(false);
    end

    function setOutput(pass)
        if strReturn
            if pass
                enabled='on';
            else
                enabled='off';
            end
        else
            enabled=pass;
        end
    end

    function pass=isOverlapsSud(selection)
        import coder.internal.mlfb.gui.MlfbUtils;
        [sudId,selectionId]=coder.internal.mlfb.idForBlock(fpt.getSud(),selection);
        pass=(sudId==selectionId)||~isempty(MlfbUtils.getBlockRelationship(sudId,selectionId));
    end

    function pass=isListViewOverlapsSud()
        [~,mlfbSid]=coder.internal.mlfb.gui.MlfbUtils.getSelectedListViewResult();
        pass=~isempty(mlfbSid)&&isOverlapsSud(mlfbSid);
    end

    function pass=hasFunctionBlocks()


        pass=~isempty(fpt.getSud().find('-isa','Stateflow.EMChart'));
    end
end
