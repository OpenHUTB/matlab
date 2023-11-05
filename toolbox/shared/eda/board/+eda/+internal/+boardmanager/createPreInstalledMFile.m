function createPreInstalledMFile(vendor,feature,boardName)

    switch feature
    case 'turnkey'
        funcName='hdlcoder_turnkey_customization';
    otherwise
        funcName='hdlverifier_fil_customization';
    end

    if nargin<=2
        hMgr=eda.internal.boardmanager.BoardManager.getInstance;
        boardNames=hMgr.getFILBoardNamesByVendor(vendor);
        factoryBoardObjs=repmat(eda.internal.boardmanager.FPGABoard,1,numel(boardNames));
        for m=1:numel(boardNames)
            factoryBoardObjs(end+1)=hMgr.getBoardObj(boardNames{m});
        end



    else
        hMgr=eda.internal.boardmanager.BoardManager.getInstance;
        factoryBoardObjs=hMgr.getBoardObj(boardName);
    end

    generator=emlhdlcoder.hdlverifier.GenMCode([funcName,'.m']);
    generator.addFuncDecl(funcName,{'cmd'},{'r'});
    generator.addComment('Copyright 2013 The MathWorks, Inc.');
    generator.addNewLine;
    generator.addIndent;

    generator.appendCode('r = [];');


    generator.addIfStatement('strcmpi(cmd,''version'')');
    generator.appendCode('r = ''1.0'';');
    generator.appendCode('return;');
    generator.addElseIfStatement('strcmpi(cmd,''getboard'')');
    initialized=false;
    for m=1:length(factoryBoardObjs)
        if strcmpi(feature,'turnkey')
            if~factoryBoardObjs(m).isTurnkeyCompatible
                continue;
            end
        elseif strcmpi(factoryBoardObjs(m).FPGA.Vendor,vendor)
            if~factoryBoardObjs(m).isFILCompatible
                continue;
            end
        else
            continue;
        end

        generator.addComment(factoryBoardObjs(m).BoardName);
        l_getBoardDefinition(factoryBoardObjs(m),generator,feature);
        if~initialized
            generator.appendCode('boardList(1) = board;');
            initialized=true;
        else
            generator.appendCode('boardList(end+1) = board;');
        end
    end
    generator.appendCode('r = boardList;');
    generator.appendCode('return;');
    generator.addEndStatement;

end


function txt=l_getBoardDefinition(fpgaBoardObj,generator,feature)
    generator.appendCode('board = eda.internal.boardmanager.FPGABoard;');
    l_getAllProperties('board',fpgaBoardObj,generator);

    generator.appendCode('board.FPGA = eda.internal.boardmanager.FPGA;');
    l_getAllProperties('board.FPGA',fpgaBoardObj.FPGA,generator);

    l_getFPGAInterface('board.FPGA',fpgaBoardObj.FPGA,generator,feature);
    txt=generator.mText;
end

function l_getAllProperties(var,obj,generator)
    p=properties(obj);
    for m=1:numel(p)
        mp=findprop(obj,p{m});
        if mp.Constant

            continue;
        end

        prop=obj.(p{m});
        if~isobject(prop)
            generator.addAssignVar([var,'.',p{m}],prop);
        end
    end
end

function l_getFPGAInterface(var,obj,generator,feature)

    interfList=obj.getInterfaceList;

    for m=1:numel(interfList)
        interface=obj.getInterface(interfList{m});
        switch feature
        case 'turnkey'

            if isa(interface,'eda.internal.boardmanager.EthInterface')
                continue;
            end
        otherwise

            if isa(interface,'eda.internal.boardmanager.UserdefinedInterface')
                continue;
            end
        end

        generator.appendCode(['interface = ',class(interface),';']);
        signalNames=interface.getSignalNames;

        if isa(interface,'eda.internal.boardmanager.UserdefinedInterface')
            for n=1:numel(signalNames)
                name=signalNames{n};
                generator.addExecFunction('signal = interface.addSignal',l_addQuote(name));
                signal=interface.getSignal(name);
                l_getAllProperties('signal',signal,generator);
            end
        else
            for n=1:numel(signalNames)
                name=signalNames{n};
                pin=interface.getFPGAPin(name);
                io=interface.getIOStandard(name);
                generator.addExecFunction('interface.setPin',{l_addQuote(name),l_addQuote(pin),l_addQuote(io)});
            end
        end

        paramNames=interface.getParamNames;
        for n=1:numel(paramNames)
            name=paramNames{n};
            param=interface.getParam(name);
            generator.addExecFunction('interface.setParam',{l_addQuote(name),l_addQuote(param)});
        end
        generator.appendCode([var,'.setInterface(interface);']);
    end
end

function r=l_addQuote(str)
    r=['''',str,''''];
end
