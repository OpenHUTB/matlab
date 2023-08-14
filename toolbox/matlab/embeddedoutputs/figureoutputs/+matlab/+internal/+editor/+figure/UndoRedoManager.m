classdef UndoRedoManager<handle


    properties(SetAccess=private,GetAccess=private)
        UndoRedoCodeGenerator matlab.internal.editor.figure.UndoRedoCodeGenerator

FigureChangedListener
    end


    methods(Access=public)
        function this=UndoRedoManager(fig,codeGenerator)
            this.UndoRedoCodeGenerator=matlab.internal.editor.figure.UndoRedoCodeGenerator(fig,...
            matlab.internal.editor.figure.Registrator());




            this.setFigureChangedListener(codeGenerator);
        end




        function performUndoRedoCallback(this,hFig,figureID,eventArgs)
            if~isempty(eventArgs)
                eventType=lower(eventArgs.type);
                showCodeGen=false;


                cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>

                switch eventType
                case 'undo'

                    warnstate=warning('off','MATLAB:handle_graphics:exceptions:SceneNode');


                    uiundo(hFig,'execUndo');


                    drawnow update
                    warning(warnstate);

                    if eventArgs.codeGenState.attachCodeGenOnUndo
                        showCodeGen=true;
                    end
                    this.transportFigureData(hFig,figureID,eventArgs,showCodeGen);
                case 'redo'

                    warnstate=warning('off','MATLAB:handle_graphics:exceptions:SceneNode');


                    uiundo(hFig,'execRedo');

                    drawnow update
                    warning(warnstate);

                    if eventArgs.codeGenState.attachCodeGenOnRedo
                        showCodeGen=true;
                    end
                    this.transportFigureData(hFig,figureID,eventArgs,showCodeGen);
                otherwise
                    return
                end
            end
        end


        function registerUndoRedoAction(this,hObj,action)
            this.UndoRedoCodeGenerator.registerAction(hObj,action);
        end

        function[generatedCode,isFakeCode]=generateCodeForUndoRedo(this)
            [generatedCode,isFakeCode]=this.UndoRedoCodeGenerator.generateCode;
        end




        function setFigureChangedListener(this,hSrc)

            if isempty(this.FigureChangedListener)



                this.FigureChangedListener=addlistener(hSrc,'FigureChanged',...
                @(e,d)this.UndoRedoCodeGenerator.setFigure(d.Figure,d.ForceSet));
            end
        end
    end

    methods(Access=private)


        function transportFigureData(this,hFig,figureID,args,showCodeGen)
            import matlab.internal.editor.figure.*

            [generatedCode,isFakeCode]=this.generateCodeForUndoRedo;

            import matlab.internal.editor.*;


            if~FigureManager.useEmbeddedFigures&&strcmpi(args.interactionType,matlab.internal.editor.figure.ActionID.TOOLSTRIPINTERACTION)


                activateuimode(hFig,'');
            end
            UndoRedoManager.transportFigureDataForUndoRedoInteractions(hFig,figureID,generatedCode,showCodeGen,isFakeCode);
        end
    end

    methods(Access=private,Static)

        function transportFigureDataForUndoRedoInteractions(hFig,figureID,generatedCode,showCodeGen,isFakeCode)
            import matlab.internal.editor.figure.FigureDataTransporter

            mData=FigureDataTransporter.getFigureMetaData(hFig,generatedCode);
            mData.setUndoRedo(true);
            mData.setFakeCode(isFakeCode);


            if~showCodeGen
                mData.iFigureInteractionData.iClearCode=true;
            else
                mData.iFigureInteractionData.iShowCode=true;
            end

            FigureDataTransporter.transportFigureData(figureID,mData);

        end
    end
end

function cleanupHandle=clearWebGraphicsRestriction
    webGraphicsRestriction=feature('WebGraphicsRestriction');
    if webGraphicsRestriction
        feature('WebGraphicsRestriction',false);
        cleanupHandle=onCleanup(@()feature('WebGraphicsRestriction',true));
    else
        cleanupHandle=[];
    end
end
