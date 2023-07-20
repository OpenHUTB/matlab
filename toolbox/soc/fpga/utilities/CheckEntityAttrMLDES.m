classdef CheckEntityAttrMLDES<matlab.DiscreteEventSystem



%#codegen
%#ok<*EMCA>

    properties(Nontunable)
        dims=1;
        dtype='uint32';
        ptype='none';
    end

    properties(DiscreteState)

    end


    properties(Access=private)
    end


    methods
        function obj=CheckEntityAttrMLDES(varargin)
            coder.allowpcode('plain');
            obj@matlab.DiscreteEventSystem(varargin);
        end

        function[entity,events,out1]=entry(~,~,entity,~)

            events=[];
            out1=0;
        end
    end

    methods(Access=protected)
        function setupImpl(~)

        end

        function resetImpl(~)

        end

        function num=getNumInputsImpl(~)
            num=1;
        end

        function num=getNumOutputsImpl(~)
            num=1;
        end

        function[inputTypes,outputTypes]=getEntityPortsImpl(~)
            inputTypes={'type1'};
            outputTypes={''};
        end

        function[storageSpec,I,O]=getEntityStorageImpl(obj)
            storageSpec=[obj.queueFIFO('type1',1)];
            I=1;
            O=0;
        end
        function entityTypes=getEntityTypesImpl(obj)
            t1=obj.entityType('type1');

            entityTypes=[t1];
        end
        function s=getOutputSizeImpl(obj)
            s=1;
            if obj.dims==-1

            else
                di=propagatedInputSize(obj,1);
                if~isempty(di)



                    dlgElems=prod(obj.dims);
                    diElems=prod(di);
                    dlgFirstIsNumElems=(obj.dims(1)==dlgElems);
                    diFirstIsNumElems=(di(1)==diElems);
                    errDlgDims=mat2str(obj.dims);

                    if(dlgElems==diElems&&dlgFirstIsNumElems&&diFirstIsNumElems)


                    elseif((length(di)~=length(obj.dims))||...
                        (~all(di==obj.dims)))
                        errSigDims=mat2str(di);
                        obj.throwError('SigAttrDim',errDlgDims,errSigDims);
                    end
                end
            end
        end
        function dt=getOutputDataTypeImpl(obj)
            dt='double';
            if strcmp('-1',obj.dtype)

            else
                dtName=propagatedInputDataType(obj,1);
                if~isempty(dtName)
                    dlgIsFixedPoint=strncmp(obj.dtype,'fixdt(',6);
                    dtIsFixedPoint=isa(dtName,'embedded.numerictype');

                    if dtIsFixedPoint
                        dtDType=dtName;
                        dtErrStr=sprintf('fixdt(%d,%d,%d)',...
                        dtDType.Signed,dtDType.WordLength,dtDType.FractionLength);
                    else
                        if strcmp('logical',dtName)
                            dtName='boolean';
                        end
                        dtErrStr=sprintf('%s',dtName);
                    end

                    if dlgIsFixedPoint
                        dlgDType=numerictype(eval(obj.dtype));
                        dlgErrStr=sprintf('fixdt(%d,%d,%d)',...
                        dlgDType.Signed,dlgDType.WordLength,dlgDType.FractionLength);
                    else
                        dlgErrStr=sprintf('%s',obj.dtype);
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


                            if strcmp(dtName,'single')||strcmp(dtName,'double')
                                haveMismatch=true;
                            else
                                dtDType=numerictype(dtName);
                                if(dlgDType.Signed~=dtDType.Signed)||...
                                    (dlgDType.WordLength~=dtDType.WordLength)||...
                                    (dlgDType.FractionLength~=dtDType.FractionLength)
                                    haveMismatch=true;
                                else
                                    haveMismatch=false;
                                end
                            end
                        else

                            if~strcmp(dtName,obj.dtype)
                                haveMismatch=true;
                            else
                                haveMismatch=false;
                            end
                        end
                    end

                    if haveMismatch
                        obj.throwError('SigAttrDType',dlgErrStr,dtErrStr);
                    end
                end
            end
        end

        function[sigAttr,bpath]=getBlkErrStrings(obj,sigAttr)
            ppath=get_param(gcbh,'Parent');
            switch obj.ptype
            case 'register',bpath=fileparts(ppath);
            case 'memory',bpath=fileparts(fileparts(fileparts(ppath)));
            case 'interrupt',bpath=fileparts(fileparts(fileparts(ppath)));sigAttr=[sigAttr,'IntCh'];
            otherwise,bpath=ppath;
            end
        end

        function throwError(obj,sigAttr,currVal,newVal)
            [sigAttr,blockPath]=obj.getBlkErrStrings(sigAttr);
            msg=message(['soc:msgs:',sigAttr],blockPath,newVal,currVal);
            sldiagviewer.reportError(MSLException(msg));
        end
    end
end
