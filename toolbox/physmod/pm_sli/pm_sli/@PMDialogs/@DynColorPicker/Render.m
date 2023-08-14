function[retVal,schema]=Render(hThis,schema)%#ok












    retVal=true;

    try
        pbutton.Name='';
        pbutton.Type='pushbutton';
        pbutton.Tag=hThis.ObjId;
        pbutton.RowSpan=[1,1];
        pbutton.ColSpan=[2,3];
        pbutton.Enabled=1;
        pbutton.MinimumSize=[37,26];
        pbutton.MaximumSize=[37,26];
        pbutton.Source=hThis;
        pbutton.ObjectMethod='OnColorButton';
        pbutton.MethodArgs={'%dialog','%source'};
        pbutton.ArgDataTypes={'handle','handle'};
        pbutton.BackgroundColor=str2num(hThis.ColorVector)*255;%#ok
        pbutton.FilePath=[matlabroot,filesep,'toolbox',filesep,'physmod'...
        ,filesep,'mech',filesep,'mech',filesep,'private'...
        ,filesep,'color_picker.png'];
        pbutton.Alignment=1;

        colorLabel.Type='text';
        colorLabel.Name=hThis.ColorLabel;
        colorLabel.RowSpan=[1,1];
        colorLabel.ColSpan=[1,1];

        mainGroup.Name='';
        mainGroup.Type='panel';
        mainGroup.Tag=hThis.ObjId;
        mainGroup.LayoutGrid=[1,3];
        mainGroup.RowSpan=[1,1];
        mainGroup.ColSpan=[1,1];
        mainGroup.Items=[];
        mainGroup.Items={colorLabel,pbutton};
        mainGroup.ColStretch=[1,1,1];
        mainGroup.RowStretch=0;
        schema=mainGroup;

    catch exception
        retVal=false;%#ok
        rethrow(exception);
    end


