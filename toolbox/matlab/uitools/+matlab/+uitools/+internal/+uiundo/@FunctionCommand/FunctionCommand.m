classdef FunctionCommand<matlab.uitools.internal.uiundo.AbstractCommand&dynamicprops




    properties
        Function function_handle
        Varargin cell
        InverseFunction function_handle
        InverseVarargin cell
    end

    methods
        function execute(hObj)
            try
                feval(hObj.Function,hObj.Varargin{:});
            catch ex
                newExc=MException('MATLAB:execute:CommandExecutionFailed','%s',...
                getString(message('MATLAB:uistring:uiundo:CommandExecutionFailed',...
                ex.message)));
                newExc=newExc.addCause(ex);
                throw(newExc);
            end
        end

        function undo(hObj)
            try
                feval(hObj.InverseFunction,hObj.InverseVarargin{:});
            catch ex
                newExc=MException('MATLAB:undo:CannotUndoCommand','%s',...
                getString(message('MATLAB:uistring:uiundo:CannotUndoCommand',...
                ex.message)));
                newExc=newExc.addCause(ex);
                throw(newExc);
            end
        end

        function redo(h)
            execute(h);
        end

        function[str]=tomcode(hObj)
            strFunction=func2str(hObj.Function);
            strArgs=locGenArgStr(hObj);
            strComment=getString(message('MATLAB:uistring:uiundo:CommentCalledBy',lower(hObj.Name)));

            str=sprintf('%s(%s); %s',strFunction,strArgs,strComment);
        end


        function[strArgs]=locGenArgStr(hObj)


            strArgs='';


            vargin=hObj.Varargin;

            for k=1:length(vargin)
                arg=vargin{k};
                str='...';



                if ishandle(arg)&&arg~=0
                    h=handle(arg);
                    str=sprintf('h_%s',h.classhandle.Name);


                elseif isnumeric(arg)

                    [s]=size(arg);


                    if ndims(s)<=2
                        str=num2str(arg,' %0.5g,');
                    end

                    str=sprintf('[%s]',str);


                elseif ischar(arg)
                    str=['''',arg,''''];


                else
                    error(message('MATLAB:tomcode:Assert'));
                end


                if k>1
                    strArgs=sprintf('%s, %s',strArgs,str);
                else
                    strArgs=str;
                end
            end
        end
    end
end


