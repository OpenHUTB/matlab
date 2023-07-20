function target=getRMISLTarget(src,isReverse,outputAsObj)















    target=src;

    if nargin<2
        isReverse=false;
    end

    if nargin<3
        outputAsObj=false;
    end

    if isa(src,'double')
        rt=sfroot;
        if~rt.isValidSlObject(src)

            srcObj=rt.idToHandle(src);
        else

            try
                srcObj=get(src,'Object');
            catch ex %#ok<NASGU>
                return;
            end
        end
    elseif isa(src,'Stateflow.Object')
        srcObj=src;
    end

    if isReverse
        if isa(srcObj,'Simulink.SubSystem')
            objParent=srcObj.getParent;
            if isa(objParent,'Stateflow.Object')


                slfObjs=objParent.find('-isa','Stateflow.SLFunction','-or','-isa','Stateflow.SimulinkBasedState');
                for index=1:length(slfObjs)
                    cfObj=slfObjs(index);
                    subSys=cfObj.getDialogProxy();
                    subHandle=subSys.Handle;
                    if subHandle==src
                        if outputAsObj
                            target=cfObj;
                        else
                            target=cfObj.id;
                        end
                        break;
                    end
                end
            end
        end
    else
        if is_simulinkstate(srcObj)
            trgtObj=srcObj.getDialogProxy;
            if outputAsObj
                target=trgtObj;
            else
                target=trgtObj.Handle;
            end
        end
    end
end


function out=is_simulinkstate(obj)
    out=isa(obj,'Stateflow.SLFunction')||isa(obj,'Stateflow.SimulinkBasedState');
end