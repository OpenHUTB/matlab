function out=getSource(varargin)


    narginchk(0,1);

    editor=[];
    studio=[];
    modelH=[];
    modelName='';

    if nargin==0||isempty(varargin{1})

        st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        if~isempty(st)
            studio=st(1);
            editor=studio.App.getActiveEditor;
            modelH=bdroot(studio.App.blockDiagramHandle);
            modelName=get_param(modelH,'Name');
        end
    elseif nargin==1
        input=varargin{1};
        if isa(input,'GLUE2.Editor')

            editor=input;
            studio=editor.getStudio;
            modelH=bdroot(studio.App.blockDiagramHandle);
            modelName=get_param(modelH,'Name');
        elseif isa(input,'DAS.Studio')

            studio=input;
            editor=studio.App.getActiveEditor;
            modelH=bdroot(studio.App.blockDiagramHandle);
            modelName=get_param(modelH,'Name');
        else

            if isa(input,'SLM3I.Diagram')

                diag=input;
                modelH=bdroot(diag.handle);
                modelName=get_param(modelH,'Name');
            elseif ischar(input)

                modelName=input;
                if bdIsLoaded(modelName)
                    modelH=get_param(modelName,'handle');
                end
            elseif ishandle(input)

                modelH=input;
                modelName=get_param(modelH,'Name');
            end

            st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            for i=1:length(st)
                s=st(i);
                es=s.App.getAllEditors;
                for j=1:length(es)
                    e=es(j);
                    h=bdroot(e.blockDiagramHandle);
                    if h==modelH
                        out.studio=s;
                        out.editor=e;
                        out.modelH=s.App.blockDiagramHandle;
                        out.modelName=get_param(out.modelH,'Name');
                        return;
                    end
                end
                if s.App.blockDiagramHandle==modelH
                    out.studio=s;
                    out.editor=s.App.getActiveEditor;
                    out.modelH=modelH;
                    out.modelName=get_param(out.modelH,'Name');
                    return;
                end
            end
        end
    end


    out.editor=editor;
    out.studio=studio;
    out.modelH=modelH;
    out.modelName=modelName;
