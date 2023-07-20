function CheckSigAttrL2SFcn(block)


    setup(block);

end

function setup(block)


    block.NumInputPorts=1;
    block.NumOutputPorts=0;


    block.SetPreCompInpPortInfoToDynamic;
    block.InputPort(1).SamplingMode='Inherited';
    block.InputPort(1).DimensionsMode='Inherited';
    block.InputPort(1).SampleTime=[-1,0];


    block.NumDialogPrms=4;
    block.DialogPrmsTunable={'Nontunable','Nontunable','Nontunable','Nontunable'};


    block.NumContStates=0;




    block.SetAccelRunOnTLC(false);
    block.SimStateCompliance='HasNoSimState';
    block.AllowSignalsWithMoreThan2D=true;




    block.RegBlockMethod('SetInputPortSamplingMode',@SetInpPortSamplingMode);
    block.RegBlockMethod('SetInputPortDimensionsMode',@SetInpPortDimsMode);
    block.RegBlockMethod('SetInputPortSampleTime',@SetInpPortST);
    block.RegBlockMethod('SetInputPortDimensions',@SetInpPortDims);
    block.RegBlockMethod('SetInputPortDataType',@SetInpPortDataType);


end





function SetInpPortSamplingMode(block,idx,sm)
    block.InputPort(idx).SamplingMode=sm;
end

function SetInpPortDimsMode(block,idx,dm)
    block.InputPort(idx).DimensionsMode=dm;
end


function SetInpPortST(block,idx,st)%#ok<INUSL>
    dlgSTime=block.DialogPrm(1).Data;
    if dlgSTime~=-1
        if st(2)~=0
            if numel(dlgSTime)~=2
                errSigSTime=mat2str(st);
                errDlgSTime=mat2str(dlgSTime);
                l_throwError(block,'SigAttrSTime',errDlgSTime,errSigSTime);
            elseif(abs(st(1)-dlgSTime(1))>=100*eps(st(1)))||...
                (abs(st(2)-dlgSTime(2))>=100*eps(st(2)))
                errSigSTime=mat2str(st);
                errDlgSTime=mat2str(dlgSTime);
                l_throwError(block,'SigAttrSTime',errDlgSTime,errSigSTime);
            end
        else
            if numel(dlgSTime)~=1
                errSigSTime=mat2str(st);
                errDlgSTime=mat2str(dlgSTime);
                l_throwError(block,'SigAttrSTime',errDlgSTime,errSigSTime);
            elseif(abs(st(1)-dlgSTime(1))>=100*eps(st(1)))
                errSigSTime=mat2str(st(1));
                errDlgSTime=mat2str(dlgSTime(1));
                l_throwError(block,'SigAttrSTime',errDlgSTime,errSigSTime);
            end
        end
    end

    block.InputPort(1).SampleTime=st;
end


function SetInpPortDataType(block,idx,dt)
    dlgDType=block.DialogPrm(3).Data;

    if dt==-1

    else
        dtName=block.DatatypeName(dt);
        dtIsFixedPoint=strncmp(dtName,'ufix',4)||strncmp(dtName,'sfix',4);
        dtIsFloat=strcmp(dtName,'single')||strcmp(dtName,'double');
        dlgIsFixedPoint=isa(dlgDType,'Simulink.NumericType');

        if~dtIsFloat
            dtDType=block.FixedPointNumericType(dt);
        end

        if dtIsFixedPoint
            dtErrStr=sprintf('fixdt(%d,%d,%d)',...
            dtDType.Signed,dtDType.WordLength,dtDType.FractionLength);
        else
            dtErrStr=sprintf('%s',dtName);
        end
        if dlgIsFixedPoint

            dlgErrStr=sprintf('fixdt(%d,%d,%d)',...
            dlgDType.Signed,dlgDType.WordLength,dlgDType.FractionLength);
        else
            dlgErrStr=sprintf('%s',dlgDType);
        end

        haveMismatch=false;%#ok<NASGU>

        if dtIsFixedPoint
            if dlgIsFixedPoint

                if(dlgDType.Signed~=dtDType.Signed)||...
                    (dlgDType.WordLength~=dtDType.WordLength)||...
                    (dlgDType.FractionLength~=dtDType.FractionLength)
                    haveMismatch=true;
                else
                    haveMismatch=false;
                end
            else
                haveMismatch=true;
            end
        else
            if dlgIsFixedPoint


                if dtIsFloat
                    haveMismatch=true;
                else
                    if(dlgDType.Signed~=dtDType.Signed)||...
                        (dlgDType.WordLength~=dtDType.WordLength)||...
                        (dlgDType.FractionLength~=dtDType.FractionLength)
                        haveMismatch=true;
                    else
                        haveMismatch=false;
                    end
                end
            else

                if~strcmp(dtName,dlgDType)
                    haveMismatch=true;
                else
                    haveMismatch=false;
                end
            end
        end

        if dtIsFixedPoint&&dtDType.WordLength>128


            error(message('soc:msgs:DWGreaterThan128',dtDType.WordLength));
        elseif haveMismatch
            l_throwError(block,'SigAttrDType',dlgErrStr,dtErrStr);
        end
    end

    block.InputPort(idx).DataTypeID=dt;

end


function SetInpPortDims(block,idx,di)
    dlgDims=block.DialogPrm(2).Data;




    dlgElems=prod(dlgDims);
    diElems=prod(di);
    dlgFirstIsNumElems=(dlgDims(1)==dlgElems);
    diFirstIsNumElems=(di(1)==diElems);

    errDlgDims=mat2str(dlgDims);

    if(dlgElems==diElems&&dlgFirstIsNumElems&&diFirstIsNumElems)


    elseif((length(di)~=length(dlgDims))||...
        (~all(di==dlgDims)))
        errSigDims=mat2str(di);
        l_throwError(block,'SigAttrDim',errDlgDims,errSigDims);
    end

    block.InputPort(idx).Dimensions=di;

end

function[sigAttr,ptype,bpath]=l_getBlkErrStrings(block,sigAttr)
    ptype=block.DialogPrm(4).Data;
    ppath=get_param(block.BlockHandle,'Parent');
    switch ptype
    case 'register',bpath=fileparts(ppath);
    case 'memory',bpath=fileparts(fileparts(fileparts(ppath)));
    case 'interrupt',bpath=fileparts(fileparts(fileparts(ppath)));sigAttr=[sigAttr,'IntCh'];
    otherwise,ptype='';bpath=ppath;
    end

end

function l_throwError(block,sigAttr,currVal,newVal)
    [sigAttr,~,blockPath]=l_getBlkErrStrings(block,sigAttr);
    msg=message(['soc:msgs:',sigAttr],blockPath,newVal,currVal);
    sldiagviewer.reportError(MSLException(msg));

end
