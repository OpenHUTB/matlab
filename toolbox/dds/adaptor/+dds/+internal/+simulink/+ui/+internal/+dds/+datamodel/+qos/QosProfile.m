classdef QosProfile<dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary



    properties(Access=private)
        mData;
    end

    methods
        function this=QosProfile(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary(mdl,tree,node);
        end

        function dlgstruct=getDialogSchema(this,arg)
            dlgstruct=getDialogSchema@dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary(this,arg);

            baseLabel.Type='text';
            baseLabel.Name=message('dds:ui:QosBase').getString;
            baseLabel.RowSpan=[1,1];
            baseLabel.ColSpan=[1,1];

            baseName.Type='edit';
            baseName.Tag='basename';
            try
                baseName.Value=dds.internal.simulink.ui.internal.dds.datamodel.qos.Qos.getFullPath(this.mNode.Base);
            catch
                baseName.Value='';
            end
            baseName.Enabled=false;
            baseName.RowSpan=[1,1];
            baseName.ColSpan=[2,2];

            panel.Type='panel';
            panel.LayoutGrid=[1,2];
            panel.ColStretch=[0,1];
            panel.Items={baseLabel,baseName};

            newItems={panel};
            for i=1:numel(dlgstruct.Items)
                newItems{end+1}=dlgstruct.Items{i};
            end
            dlgstruct.Items=newItems;
            dlgstruct.LayoutGrid=[3,1];

        end

        function domainObj=duplicate(this)
            qosLibNode=this.mNode.Container;
            [profileNames,profileObjs]=dds.internal.simulink.ui.internal.dds.datamodel.qos.QosLibrary.getProfileList(qosLibNode);
            txn=this.mMdl.beginTransaction;
            profileObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.duplicateElement(this.mMdl,profileNames,this.mNode,'');
            qosLibNode.QosProfiles.add(profileObj);
            txn.commit;
        end
    end


    methods(Static,Access=public)


    end



    methods(Access=private)


    end
end
