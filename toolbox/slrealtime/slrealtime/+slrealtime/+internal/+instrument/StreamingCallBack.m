classdef StreamingCallBack<handle







%# private constructor
    methods(Access=private)
        function obj=StreamingCallBack()
        end
    end

    methods(Static)

        function NewData(cbg)
            targets=unique({cbg.targetComputer});
            for i=1:length(targets)

                cbgs=cbg(arrayfun(@(x)strcmp(x.targetComputer,targets{i}),cbg));
                if~isempty(cbgs)
                    funchandle=cbgs(1).fcnHandle;
                    if~isempty(funchandle)
                        funchandle(cbgs);
                    end
                end
            end
        end
    end
end
