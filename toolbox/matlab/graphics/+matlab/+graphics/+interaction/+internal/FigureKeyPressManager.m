classdef FigureKeyPressManager<matlab.ui.internal.FigureKeyPressForwardingSuppressor





    methods(Static)
        function hManager=registerObject(hObj,keys)















            import matlab.graphics.interaction.internal.FigureKeyPressManager


            assert(isscalar(hObj)&&isa(hObj,'handle'),...
            [FigureKeyPressManager.MessageID,'InvalidObject'],...
            'First input must be a scalar graphics object.');


            assert(ischar(keys)||iscellstr(keys)||isstring(keys),...
            [FigureKeyPressManager.MessageID,'InvalidKeys'],...
            'Second input must be a string array, character vector, or cell-array of character vectors.');
            keys=string(keys);
            keys=keys(:)';


            hFigure=ancestor(hObj,'matlab.ui.Figure');

            if isscalar(hFigure)

                hManager=FigureKeyPressManager.getManager(hFigure);



                ind=hManager.findObject(hObj);




                if isempty(ind)
                    ind=numel(hManager.Keys)+1;
                    hManager.DeleteObjectListeners(ind)=hObj.listener(...
                    'ObjectBeingDestroyed',@(~,~)...
                    FigureKeyPressManager.unregisterObject(hObj));
                end


                hManager.Keys{ind}=keys;
            else

                hManager=FigureKeyPressManager.empty();
            end

            if nargout==0
                clear('hManager')
            end
        end

        function unregisterObject(hObj,hManager)
















            import matlab.graphics.interaction.internal.FigureKeyPressManager


            assert(isscalar(hObj)&&isa(hObj,'handle'),...
            [FigureKeyPressManager.MessageID,'InvalidObject'],...
            'First input must be a scalar graphics object.');


            haveManager=false;
            if nargin==2

                assert((isa(hManager,'matlab.ui.Figure')||...
                isa(hManager,'matlab.graphics.interaction.internal.FigureKeyPressManager'))&&...
                isscalar(hManager)&&isvalid(hManager),...
                [FigureKeyPressManager.MessageID,'InvalidManager'],...
                'Second input must be a figure or manager.');


                if isa(hManager,'matlab.graphics.interaction.internal.FigureKeyPressManager')
                    hFigure=hManager.DeleteListener.Source{1};
                    haveManager=true;
                else
                    hFigure=hManager;
                end
            else

                hFigure=ancestor(hObj,'figure');
            end



            if isscalar(hFigure)&&strcmp(hFigure.BeingDeleted,'off')...
                &&(haveManager||FigureKeyPressManager.hasManager(hFigure))


                if~haveManager
                    hManager=FigureKeyPressManager.getManager(hFigure);
                end



                ind=hManager.findObject(hObj);



                if isscalar(ind)
                    hManager.DeleteObjectListeners(ind)=[];
                    hManager.Keys(ind)=[];
                end



                if isempty(hManager.DeleteObjectListeners)
                    hManager.delete();
                end
            end
        end
    end

    methods(Hidden)
        function delete(hManager)


            import matlab.graphics.interaction.internal.FigureKeyPressManager


            hFigure=hManager.DeleteListener.Source{1};
            if isscalar(hFigure)&&isvalid(hFigure)&&strcmp(hFigure.BeingDeleted,'off')

                p=findprop(hFigure,FigureKeyPressManager.PropertyName);
                delete(p);
            end
        end

        function hObj=saveobj(hObj)%#ok<MANU>


            import matlab.graphics.interaction.internal.FigureKeyPressManager


            error([FigureKeyPressManager.MessageID,'SavingDisabled'],...
            'Saving the FigureKeyPressManager is not supported.');
        end
    end

    properties(Transient,Access=?tFigureKeyPressManager)



        Keys=cell(0,1)


        KeyPressListener=event.listener.empty


        DeleteListener=event.listener.empty


        DeleteObjectListeners=event.listener.empty
    end

    properties(Constant,Access=protected)

        PropertyName='KeyPressFcnManager'
        MessageID='MATLAB:graphics:FigureKeyPressManager:'
    end

    methods(Access={?tFigureKeyPressManager,...
        ?matlab.graphics.interaction.internal.FigureKeyPressManager})
        function hManager=FigureKeyPressManager(hFigure)


            import matlab.graphics.interaction.internal.FigureKeyPressManager


            hManager=hManager@matlab.ui.internal.FigureKeyPressForwardingSuppressor(hFigure);


            hManager.KeyPressListener=hFigure.listener(...
            'KeyPress',@FigureKeyPressManager.keyPressFcn);



            hManager.DeleteListener=hFigure.listener(...
            'ObjectBeingDestroyed',@(~,~)hManager.delete());
        end

        function ind=findObject(hManager,hObj)


            n=numel(hManager.DeleteObjectListeners);
            ind=[];
            for s=1:n
                if hObj==hManager.DeleteObjectListeners(s).Sources{1}
                    ind=s;
                    break
                end
            end
        end
    end

    methods(Static,Access={?tFigureKeyPressManager,...
        ?matlab.graphics.interaction.internal.FigureKeyPressManager})
        function hManager=getManager(hFigure)



            import matlab.graphics.interaction.internal.FigureKeyPressManager



            propName=FigureKeyPressManager.PropertyName;
            prop=findprop(hFigure,propName);
            if isempty(prop)

                prop=addprop(hFigure,FigureKeyPressManager.PropertyName);
                prop.Hidden=true;
                prop.Transient=true;
                prop.SetAccess='private';
            end


            if isempty(hFigure.(propName))

                hManager=FigureKeyPressManager(hFigure);
                prop.SetAccess='public';
                hFigure.(propName)=hManager;
                prop.SetAccess='private';
            else

                hManager=hFigure.(propName);
            end
        end

        function tf=hasManager(hFigure)


            import matlab.graphics.interaction.internal.FigureKeyPressManager



            propName=FigureKeyPressManager.PropertyName;
            tf=isprop(hFigure,propName)&&~isempty(hFigure.(propName));
        end

        function keyPressFcn(hFigure,eventData)


            import matlab.graphics.interaction.internal.FigureKeyPressManager




            if isempty(hFigure.KeyPressFcn)&&...
                isempty(hFigure.KeyReleaseFcn)&&...
                isempty(hFigure.WindowKeyPressFcn)&&...
                isempty(hFigure.WindowKeyReleaseFcn)
                FigureKeyPressManager.forwardToCommandWindow(hFigure,eventData);
            end
        end

    end

    methods(Static)
        function forwardToCommandWindow(hFigure,eventData)






            import matlab.graphics.interaction.internal.FigureKeyPressManager


            isModal=strcmpi(get(hFigure,'WindowStyle'),'modal');
            hasDesktop=desktop('-inuse');



            if isdeployed||isModal||~hasDesktop
                return
            end


            if isempty(eventData.Character)
                return
            end


            modifiersSize=size(eventData.Modifier);
            for i=1:modifiersSize(2)
                currentModifier=eventData.Modifier{i};
                if(strcmp(currentModifier,'control')||...
                    strcmp(currentModifier,'alt')||...
                    strcmp(currentModifier,'command'))
                    return
                end
            end



            keys="tab";
            hManager=matlab.graphics.interaction.internal.FigureKeyPressManager.empty();
            if FigureKeyPressManager.hasManager(hFigure)

                propName=FigureKeyPressManager.PropertyName;
                hManager=hFigure.(propName);


                keys=unique([hManager.Keys{:},keys]);
            end



            if any(eventData.Key==keys)
                return
            end


            hManager.forwardKeyPressToCommandWindow(hFigure,eventData.Character,eventData.Modifier,eventData.Key);
        end
    end
end
