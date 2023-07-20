function onClickNode(this,dlg)



    this.Path=['/',this.SelectedTreeItem];

    if(this.ShowPorts)
        portsPathandMode=autopopulate(...
        this.Path,...
        1,...
        double(~this.UserData.useSocket),...
        '',...
        num2str(this.UserData.SocketPort));

        assert(length(portsPathandMode)>=1,'Hdllink:Autofill:InvalidData',...
        'Received invalid data from HDL simulator');
        assert(portsPathandMode{1}~=0,'Hdllink:Autofill:InstanceNotFound',...
        ['HDL instance ',this.Path,' was not found in the loaded model.']);



        portNames=portsPathandMode(3:2:end);
        portModes=portsPathandMode(4:2:end);

        this.TableItems=cell(numel(portNames),2);

        for m=1:length(portNames)
            this.TableItems{m,1}=portNames{m};
            this.TableItems{m,2}=portModes{m};
        end

        dlg.refresh;
    end
end