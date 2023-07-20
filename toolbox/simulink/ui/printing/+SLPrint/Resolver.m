





classdef Resolver
    methods(Static)
        function uddObject=resolveToUDD(objs,convertSLToSF)


            if(nargin==1)
                convertSLToSF=false;
            end

            if isempty(objs)
                uddObject=[];

            elseif isa(objs,'DAStudio.Object')||isa(objs,'Simulink.DABaseObject')
                uddObject=objs;

            else
                if ischar(objs)
                    objs={objs};
                end

                nObjs=length(objs);
                uddObject(nObjs)=slroot;

                for i=1:nObjs
                    if iscell(objs)
                        obj=SLPrint.Resolver.internalResolveToUDD(objs{i});
                    else
                        obj=SLPrint.Resolver.internalResolveToUDD(objs(i));
                    end

                    if isempty(obj)
                        error('Simulink:Printing:UnableToResolve',...
                        'Cannot resolve: %s',disp(obj));
                    end
                    uddObject(i)=obj;
                end
            end

            if convertSLToSF
                uddObject=SLPrint.Resolver.internalBlockToChart(uddObject);
            end

        end

        function h=resolveToHandle(objs,convertSLToSF)



            if(nargin==1)
                convertSLToSF=false;
            end

            if ischar(objs)
                objs={objs};
            end

            nObjs=length(objs);
            if(nObjs>0)
                h{nObjs}=[];
            else
                h=[];
            end

            for i=1:nObjs
                if iscell(objs)
                    h{i}=SLPrint.Resolver.internalResolveToHandle(objs{i});
                else
                    h{i}=SLPrint.Resolver.internalResolveToHandle(objs(i));
                end
            end


            if convertSLToSF
                h=SLPrint.Resolver.internalBlockToChart(h);
            end

        end

        function h=resolveToDoubleHandleOrId(objs,convertSLToSF)
            if(nargin==1)
                convertSLToSF=false;
            end

            h=SLPrint.Resolver.resolveToHandle(objs,convertSLToSF);
            for i=1:length(h)
                if isa(h{i},'Stateflow.Object')||isa(h{i},'Stateflow.DDObject')
                    h{i}=h{i}.Id;
                end
            end
            h=cell2mat(h);
        end

        function elements=resolveToDiagramElements(objs)
            h=SLPrint.Resolver.resolveToDoubleHandleOrId(objs,false);
            elements=cell(1,length(h));
            for i=1:length(h)
                if SLPrint.Resolver.isSimulink(h(i))
                    udd=SLPrint.Resolver.resolveToUDD(h(i));
                    if isa(udd,'Simulink.Subsystem')



                        slfunc=Stateflow.SLINSF.SimfcnMan.getSLFunction(udd);
                    else
                        slfunc=[];
                    end

                    if~isempty(slfunc)
                        elements{i}=StateflowDI.SFDomain.id2DiagramElement(slfunc.Id);
                    else
                        elements{i}=SLM3I.SLDomain.handle2DiagramElement(h(i));
                    end
                else
                    elements{i}=StateflowDI.SFDomain.id2DiagramElement(h(i));
                end
            end
        end

        function tf=isSimulink(objs)
            h=SLPrint.Resolver.resolveToDoubleHandleOrId(objs,false);
            func=@(x)isValidSlObject(slroot,x);
            tf=arrayfun(func,h);
        end

        function tf=isStateflow(objs)
            h=SLPrint.Resolver.resolveToDoubleHandleOrId(objs);

            n=length(h);
            tf=false(n,1);
            for i=1:n
                tf(i)=~SLPrint.Resolver.isSimulink(h(i))&&...
                ~isempty(idToHandle(slroot,h(i)));
            end
        end

        function blockDiagramUDDObject=getBlockDiagramUDDObject(in)


            h=SLPrint.Resolver.getBlockDiagramHandle(in);
            blockDiagramUDDObject=get_param(h,'Object');
        end

        function blockDiagramHandle=getBlockDiagramHandle(in)


            h=SLPrint.Resolver.internalResolveToHandle(in);

            if SLPrint.Resolver.isStateflow(h)
                blockDiagramHandle=get_param(h.Machine.Name,'Handle');
            else
                blockDiagramHandle=bdroot(h);
            end
        end

    end

    methods(Static,Access=private)
        function h=internalResolveToHandle(obj)
            r=slroot;

            if r.isValidSlObject(obj)
                h=get_param(obj,'Handle');

            elseif(isnumeric(obj)&&~ishghandle(obj))
                h=r.idToHandle(obj);

                if(isa(h,'Stateflow.DDObject')&&isempty(h))
                    h=[];
                end

            elseif ishandle(obj)&&isa(obj,'Simulink.Object')
                h=obj.Handle;

            elseif ishandle(obj)&&(isa(obj,'Stateflow.Object')||isa(obj,'Stateflow.DDObject'))
                h=obj;

            else
                h=[];
            end
        end

        function udd=internalResolveToUDD(obj)
            r=slroot;
            if isa(obj,'DAStudio.Object')||isa(obj,'Simulink.DABaseObject')
                udd=obj;

            elseif r.isValidSlObject(obj)
                udd=get_param(obj,'Object');

            elseif(isnumeric(obj)&&~ishghandle(obj))
                udd=r.idToHandle(obj);

            else
                udd=[];
            end
        end

        function out=internalBlockToChart(in)
            out=in;
            if isa(in,'DAStudio.Object')||isa(in,'Simulink.DABaseObject')
                for i=1:length(in)
                    if isa(in(i),'Simulink.Subsystem')&&slprivate('is_stateflow_based_block',in(i).Handle)
                        foundChart=sf('Private','block2chart',in(i).Handle);
                        if foundChart==0
                            out(i)=[];
                        else
                            out(i)=SLPrint.Resolver.internalResolveToUDD(foundChart);
                        end
                    end
                end
            else

                for i=1:length(in)
                    if(isValidSlObject(slroot,in{i})...
                        &&strcmpi(get_param(in{i},'Type'),'block')...
                        &&slprivate('is_stateflow_based_block',in{i}))
                        foundChart=sf('Private','block2chart',in{i});
                        if foundChart==0
                            out{i}=[];
                        else
                            out{i}=SLPrint.Resolver.internalResolveToUDD(foundChart);
                        end
                    end
                end
            end
        end
    end

end
