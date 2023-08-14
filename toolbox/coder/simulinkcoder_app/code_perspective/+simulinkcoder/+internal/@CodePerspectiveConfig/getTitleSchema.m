function titlePanel=getTitleSchema(obj)



    dscr.Type='text';
    dscr.Name='add more descriptions here ...GIFs ...videos ...';
    dscr.WordWrap=true;
    dscr.MinimumSize=[0,100];
    dscr.BackgroundColor=[250,250,250];

    titlePanel.Type='group';
    titlePanel.Name='Description';
    titlePanel.Items={dscr};

