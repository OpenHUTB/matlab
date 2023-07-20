function out=getTargetHardwareDialogSchema(component,varargin)






    widget.Items={};
    deviceDetails=[];
    cs=component.getConfigSet;
    if~isempty(cs)
        stf=cs.get_param('SystemTargetFile');
        if strcmp(stf,'realtime.tlc')&&cs.isValidParam('TargetExtensionPlatform')
            hardwareBoardValue=cs.get_param('TargetExtensionPlatform');
        else
            hardwareBoardValue=cs.getProp('HardwareBoard');
        end
        if~isequal(hardwareBoardValue,'None')
            deviceDetails.Type='group';
            deviceDetails.Name=DAStudio.message('codertarget:build:HardwareBoardSettings');
            deviceDetails.LayoutGrid=[1,1];
            deviceDetails.Items={codertarget.utils.getTargetHardwareDetailWidgets(component)};
            deviceDetails.RowSpan=[2,2];
            deviceDetails.ColSpan=[1,2];
            widget.Items={deviceDetails};
        end
    end

    if nargin==2&&strcmp(varargin{1},'web')

        if isempty(deviceDetails)
            info='';
        else
            info=configset.internal.util.convertDDGSchema(deviceDetails);
        end
        out.info=info;
        out.handler='coderTarget';
    else
        out=widget;
    end
