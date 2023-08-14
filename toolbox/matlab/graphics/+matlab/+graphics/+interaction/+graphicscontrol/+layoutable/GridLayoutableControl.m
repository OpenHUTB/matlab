classdef GridLayoutableControl<matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControl




    properties(Constant,Access='private',NonCopyable,Transient)
        VisibilityProp="InitialVisibility"
        VisibilityModeProp="InitialVisibilityMode"

        ContentsVisibilityProp="InitialContentsVisiblility"
        ContentsVisibilityModeProp="InitialContentsVisiblilityMode"
    end

    methods
        function this=GridLayoutableControl(obj)
            import matlab.graphics.interaction.*
            this=this@matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControl(obj);
            this.Type='gridlayoutable';















            if obj.isInGridLayout()&&...
                ~obj.Parent.isInDesignTime()&&...
                ~isprop(obj,this.VisibilityProp)...

                p=obj.addprop(this.VisibilityModeProp);
                p.Transient=true;
                p.Hidden=true;
                p.NonCopyable=true;
                set(obj,this.VisibilityModeProp,obj.VisibleMode);

                p=obj.addprop(this.VisibilityProp);
                p.Transient=true;
                p.Hidden=true;
                p.NonCopyable=true;
                set(obj,this.VisibilityProp,obj.Visible_I);

                obj.Visible_I=false;
                obj.VisibleMode='auto';

                if(isprop(obj,'ContentsVisible'))
                    p=obj.addprop(this.ContentsVisibilityProp);
                    p.Transient=true;
                    p.Hidden=true;
                    p.NonCopyable=true;
                    set(obj,this.ContentsVisibilityProp,obj.ContentsVisible_I);

                    p=obj.addprop(this.ContentsVisibilityModeProp);
                    p.Transient=true;
                    p.Hidden=true;
                    p.NonCopyable=true;
                    set(obj,this.ContentsVisibilityModeProp,obj.ContentsVisibleMode);

                    obj.ContentsVisible_I=false;
                    obj.ContentsVisibleMode='auto';
                end
            end
        end


        function tf=needsSetup(obj)%#ok<MANU>
            tf=true;
        end

        function msg=generateLayoutConstraintsMsg(obj,objInGrid)%#ok<INUSL>
            layoutOptions=objInGrid.Layout;
            msg=matlab.ui.control.internal.controller.mixin.LayoutableController.convertContraintsToStruct(layoutOptions);
            msg.cmd='modelSideLayoutChanged';
        end

        function lay=getLayout(this)
            layoutOptions=this.Obj.Layout;
            lay=matlab.ui.control.internal.controller.mixin.LayoutableController.convertContraintsToStruct(layoutOptions);
        end

        function response=process(this,message)

            response=struct;
            if isfield(message,'name')&&ischar(message.name)
                switch message.name
                case matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControlEnums.getLayoutConstraints
                    response.Layout=this.getLayout();
                case matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControlEnums.setOuterPosition
                    response=process@matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControl(this,message);
                    visPropName=this.VisibilityProp;
                    visModePropName=this.VisibilityModeProp;

                    contentsVisPropName=this.ContentsVisibilityProp;
                    contentsVisModePropName=this.ContentsVisibilityModeProp;

                    if this.Obj.isprop(visPropName)




                        if strcmp(this.Obj.VisibleMode,'auto')
                            this.Obj.Visible_I=this.Obj.(visPropName);
                            this.Obj.VisibleMode=this.Obj.(visModePropName);
                        end

                        mp=findprop(this.Obj,this.VisibilityProp);
                        delete(mp);

                        mp=findprop(this.Obj,this.VisibilityModeProp);
                        delete(mp);
                    end

                    if this.Obj.isprop(contentsVisPropName)




                        if strcmp(this.Obj.ContentsVisibleMode,'auto')
                            this.Obj.ContentsVisible_I=this.Obj.(contentsVisPropName);
                            this.Obj.ContentsVisibleMode=this.Obj.(contentsVisModePropName);
                        end

                        mp=findprop(this.Obj,this.ContentsVisibilityProp);
                        delete(mp);

                        mp=findprop(this.Obj,this.ContentsVisibilityModeProp);
                        delete(mp);
                    end
                otherwise

                    response=process@matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControl(this,message);
                end
            end
        end
    end
end
