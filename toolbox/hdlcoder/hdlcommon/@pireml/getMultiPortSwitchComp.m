function multiportSwitchComp=getMultiPortSwitchComp(hN,hInSignals,...
    hOutSignals,inputmode,dataPortOrder,rndMode,satMode,compName,portSel,codingStyle)




    if nargin<10||isempty(codingStyle)
        codingStyle='ifelse_stmt';
    end

    if nargin<9
        portSel=[];
    end

    if nargin<8
        compName='multiportswitch';
    end

    if nargin<7
        satMode='wrap';
    end

    if nargin<6
        rndMode='floor';
    end

    if strcmp(dataPortOrder,'Zero-based contiguous')
        blockMode=1;
    elseif strcmp(dataPortOrder,'One-based contiguous')
        blockMode=0;
    else
        blockMode=2;
    end

    blkImplCase=false;

    if strcmpi(codingStyle,'case_stmt')
        blkImplCase=true;
    end



    tcOut=hdlhandles(numel(hInSignals),1);
    tcOut(1)=hInSignals(1);






    if(~tcOut(1).Type.BaseType.isEnumType)
        Sel_WL=tcOut(1).Type.BaseType.WordLength;
        if(Sel_WL>64)
            Sel_Sign=tcOut(1).Type.Signed;
            rndMode='floor';
            satMode='wrap';
            if(Sel_Sign==1)
                Sel_outType=pir_sfixpt_t(64,0);
            else
                Sel_outType=pir_ufixpt_t(64,0);
            end
            tcOut(1)=pireml.insertDTCCompOnInput(hN,hInSignals(1),...
            Sel_outType,rndMode,satMode);
        else
            tcOut(1)=hInSignals(1);
        end
    else
        tcOut(1)=hInSignals(1);
    end
    outType=hOutSignals(1).Type;
    for ii=2:numel(hInSignals)
        inType=hInSignals(ii).Type;
        inLeafType=inType.getLeafType;
        if outType.isArrayType
            outLeafType=outType.getLeafType;
            if inType.isArrayType

                if~outLeafType.isEqual(inLeafType)
                    tcOut(ii)=pireml.insertDTCCompOnInput(hN,hInSignals(ii),...
                    outType,rndMode,satMode);
                else

                    tcOut(ii)=hInSignals(ii);
                end
            else

                if~outLeafType.isEqual(inLeafType)
                    scalarIn=pireml.insertDTCCompOnInput(hN,hInSignals(ii),...
                    outLeafType,rndMode,satMode);
                else
                    scalarIn=hInSignals(ii);
                end

                tcOut(ii)=pirelab.scalarExpand(hN,scalarIn,outType.getDimensions);
            end
        elseif~outType.isEqual(inLeafType)
            tcOut(ii)=pireml.insertDTCCompOnInput(hN,hInSignals(ii),outType,...
            rndMode,satMode);
        else

            tcOut(ii)=hInSignals(ii);
        end
    end

    if inputmode==2

        selArray=pirelab.demuxSignal(hN,tcOut(1));

        inputArrays=hdlhandles(numel(selArray),numel(hInSignals)-1);
        for j=2:numel(hInSignals)
            inputArrays(:,j-1)=pirelab.demuxSignal(hN,tcOut(j));
        end

        outputMux=pirelab.getMuxOnOutput(hN,hOutSignals(1));
        outputArray=outputMux.PirInputSignals;

        for j=1:numel(selArray)

            newComp=getOneMultiPortSwitchComp(hN,[selArray(j),inputArrays(j,:)],...
            outputArray(j),1,blockMode,compName,portSel,blkImplCase);
            if j==1

                multiportSwitchComp=newComp;
            end
        end
    else

        multiportSwitchComp=getOneMultiPortSwitchComp(hN,tcOut,...
        hOutSignals,inputmode,blockMode,compName,portSel,blkImplCase);
    end
end

function multiportSwitchComp=getOneMultiPortSwitchComp(hN,hInSignals,...
    hOutSignals,inputmode,blockMode,compName,portSel,blkImplCase)
    matrixTypes=hOutSignals.Type.isMatrix;








    GenerateCaseWhenForMultiportSwitch=false;
    if blkImplCase
        GenerateCaseWhenForMultiportSwitch=true;
        if inputmode==0&&numel(hInSignals)<=2

            if hInSignals(2).Type.isArrayType
                if hInSignals(2).Type.Dimensions<=2
                    GenerateCaseWhenForMultiportSwitch=false;
                end
            else
                GenerateCaseWhenForMultiportSwitch=false;
            end
        else

            if numel(hInSignals)<=3
                GenerateCaseWhenForMultiportSwitch=false;
            end
        end
    end

    if blockMode==2
        if GenerateCaseWhenForMultiportSwitch

            fcnBody=getMultiportswitchcaseEnum(length(hInSignals));
            multiportSwitchComp=hN.addComponent2(...
            'kind','cgireml',...
            'Name',compName,...
            'InputSignals',hInSignals,...
            'OutputSignals',hOutSignals,...
            'EMLFileName','hdleml_switch_multiport_enum',...
            'EMLFileBody',fcnBody,...
            'EMLParams',{portSel},...
            'EMLFlag_RunLoopUnrolling',false,...
            'EMLFlag_ParamsFollowInputs',false,...
            'MatrixTypes',matrixTypes);
        else

            multiportSwitchComp=hN.addComponent2(...
            'kind','cgireml',...
            'Name',compName,...
            'InputSignals',hInSignals,...
            'OutputSignals',hOutSignals,...
            'EMLFileName','hdleml_switch_multiport_enum',...
            'EMLParams',{portSel},...
            'EMLFlag_RunLoopUnrolling',false,...
            'EMLFlag_ParamsFollowInputs',false,...
            'MatrixTypes',matrixTypes);
        end
    else
        zeroBasedIndex=blockMode;
        if GenerateCaseWhenForMultiportSwitch

            fcnBody=getMultiportswitchcase(inputmode,hInSignals,zeroBasedIndex);
            multiportSwitchComp=hN.addComponent2(...
            'kind','cgireml',...
            'Name',compName,...
            'InputSignals',hInSignals,...
            'OutputSignals',hOutSignals,...
            'EMLFileName','hdleml_switch_multiport',...
            'EMLFileBody',fcnBody,...
            'EMLParams',{inputmode,zeroBasedIndex},...
            'EMLFlag_RunLoopUnrolling',false,...
            'EMLFlag_ParamsFollowInputs',false,...
            'MatrixTypes',matrixTypes);
        else

            multiportSwitchComp=hN.addComponent2(...
            'kind','cgireml',...
            'Name',compName,...
            'InputSignals',hInSignals,...
            'OutputSignals',hOutSignals,...
            'EMLFileName','hdleml_switch_multiport',...
            'EMLParams',{inputmode,zeroBasedIndex},...
            'EMLFlag_RunLoopUnrolling',false,...
            'EMLFlag_ParamsFollowInputs',false,...
            'MatrixTypes',matrixTypes);
        end
    end

    multiportSwitchComp.runWebRenaming(false);
    if targetmapping.isValidDataType(hInSignals(2).Type)
        multiportSwitchComp.setSupportTargetCodGenWithoutMapping(true);
    end
end


function fcnBody=getMultiportswitchcaseEnum(siglen)
    fcnBody=sprintf(['%%#codegen\n',...
    'function y = hdleml_switch_multiport_enum(portIndices, sel, varargin)\n',...
    '%%   Copyright 2018 The MathWorks, Inc.\n',...
    'coder.allowpcode(''plain'')\n',...
    'eml_prefer_const(portIndices);\n']);

    fcnBody=sprintf('%sswitch sel\n',fcnBody);

    for ii=1:siglen-2
        fcnBody=sprintf('%s\tcase portIndices(%d)\n\t\ty = varargin{%d};\n',...
        fcnBody,ii,ii);
    end


    fcnBody=sprintf('%s\totherwise \n\t\ty = varargin{end};\n',fcnBody);
    fcnBody=sprintf('%send\n',fcnBody);

end


function fcnBody=getMultiportswitchcase(inputmode,hInSignals,zeroBasedIndex)
    siglen=length(hInSignals);


    fcnBody=sprintf(['%%#codegen\n',...
    'function y = hdleml_switch_multiport(inputmode, zeroBasedIndex, sel, varargin)\n',...
    '%%   Copyright 2018 The MathWorks, Inc.\n',...
    'coder.allowpcode(''plain'')\n']);

    if inputmode==1
        fcnBody=sprintf('%sswitch sel\n',fcnBody);
        for ii=1:siglen-2
            fcnBody=sprintf('%s\tcase %d\n\t\ty = varargin{%d};\n',...
            fcnBody,ii-zeroBasedIndex,ii);
        end

        fcnBody=sprintf('%s\totherwise \n\t\ty = varargin{end};\n',fcnBody);
        fcnBody=sprintf('%send\n',fcnBody);

    else
        fcnBody=sprintf('%seml_prefer_const(zeroBasedIndex);\n',fcnBody);
        fcnBody=sprintf('%su = varargin{1};\n',fcnBody);


        inArray=hInSignals(2);
        arrayLen=inArray.Type.Dimensions;
        if arrayLen>=1024
            fcnBody=sprintf('%sidx = sel + zeroBasedIndex;\n',fcnBody);
            fcnBody=sprintf('%sif 1 - zeroBasedIndex <= idx && idx <= numel(u) - zeroBasedIndex\n',fcnBody);
            fcnBody=sprintf('%s\ty = u(double(idx));\nelse\n\ty = u(end)\n',fcnBody);
            fcnBody=sprintf('%send\n',fcnBody);
        else
            fcnBody=sprintf('%sswitch sel\n',fcnBody);
            for ii=1:arrayLen-1
                fcnBody=sprintf('%s\tcase %d\n\t\ty = u(%d);\n',...
                fcnBody,ii-zeroBasedIndex,ii);
            end

            fcnBody=sprintf('%s\totherwise \n\t\ty = u(end);\n',fcnBody);
            fcnBody=sprintf('%send\n',fcnBody);
        end
    end
end



