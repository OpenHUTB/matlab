


classdef Studio<handle
    properties
fStudio
fModelHandle
    end


    properties(Access=private)
        fComponents={}

        fListeners={}
    end

    methods

        function obj=Studio(st)
            obj.fStudio=st;


            obj.init();




        end


        function delete(obj)
            for i=1:numel(obj.fComponents)
                delete(obj.fComponents{i});
            end


            for i=1:numel(obj.fListeners)
                delete(obj.fListeners{i});
            end
            obj.fListeners={};



        end
    end

    methods
        init(obj)


        turnOn(obj)
        turnOff(obj)
    end

    methods(Static)

        out=getFromStudio(studio)


        function id=generateClientID()
            id=sprintf('%08x',uint32(rand*intmax('uint32')));
        end
    end

    methods

        function out=getStudio(obj)
            out=obj.fStudio;
        end


        function out=getModelHandle(obj)
            out=obj.fModelHandle;
        end


        function out=getCodeView(obj)
            for i=1:numel(obj.fComponents)
                comp=obj.fComponents{i};
                if isa(comp,'slci.view.CodeView')
                    out=comp;
                    return;
                end
            end

            out=slci.view.CodeView(obj.fStudio);
            obj.fComponents{end+1}=out;
        end


        function out=getJustification(obj)
            for i=1:numel(obj.fComponents)
                comp=obj.fComponents{i};
                if isa(comp,'slci.view.Justification')
                    out=comp;
                    return;
                end
            end

            out=slci.view.Justification(obj.fStudio);
            obj.fComponents{end+1}=out;
        end


        function out=getReport(obj)
            for i=1:numel(obj.fComponents)
                comp=obj.fComponents{i};
                if isa(comp,'slci.view.Report')
                    out=comp;
                    return;
                end
            end

            out=slci.view.Report(obj.fStudio);
            obj.fComponents{end+1}=out;
        end


        function out=getCompatibility(obj)
            for i=1:numel(obj.fComponents)
                comp=obj.fComponents{i};
                if isa(comp,'slci.view.Compatibility')
                    out=comp;
                    return;
                end
            end

            out=slci.view.Compatibility(obj.fStudio);
            obj.fComponents{end+1}=out;
        end


        function out=getResultReview(obj)
            for i=1:numel(obj.fComponents)
                comp=obj.fComponents{i};
                if isa(comp,'slci.view.ResultReview')
                    out=comp;
                    return;
                end
            end

            out=slci.view.ResultReview(obj.fStudio);
            obj.fComponents{end+1}=out;
        end
    end
end
