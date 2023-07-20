function onFill(this,dlg)



    if(this.ShowPorts)
        row=getSelectedTableRow(dlg,'edaPortList');
        if(row>=0)
            [tblRow,tblCol]=size(this.TableItems);
            assert(row<tblRow&&tblCol==2,'HdlLink:CosimWizard:InvalidTableDimension',...
            'Invalid table dimension detected');
            trigger=[this.Path,'/',this.TableItems{row+1,1}];
            setWidgetValue(this.ParentDialog,'edaTriggerSignal',trigger);
        end
    else
        setWidgetValue(this.ParentDialog,'edaCbHdlComponent',this.Path);
    end
    delete(dlg);
end


