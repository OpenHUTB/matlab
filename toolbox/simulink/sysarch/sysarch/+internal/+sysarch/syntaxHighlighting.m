function[indicator,msg]=syntaxHighlighting(~,pos,briefDesc)

    indicator=red_circle(pos);

    msg=MG2.TextNode;
    msg.Text=briefDesc;
    msg.DrawStyle.Fill.Color=[1,1,1];
    msg.DrawStyle.Stroke.Color=[0,0,0];
    msg.DrawStyle.Stroke.Style='SolidLine';
    msg.Parent=indicator;
    msg.Position=[-30,12];
    msg.Font.Style='Italic';
    msg.addTag('WhatIsThis');
    msg.Visible=false;


    function indicator=red_circle(pos)

        indicator=MG2.ImageNode;
        indicator.Path=fullfile(matlabroot,'toolbox','simulink',...
        'sysarch','sysarch','resources','red_circle.svg');
        indicator.Position=pos-[1,1];


        function indicator=l_squibblyLine(pos)

            indicator=MG2.OpenCurvedPathNode;
            x=0:12;
            y=1.35*[0,1,0,-1,0,1,0,-1,0,1,0,-1,0,1,0];
            for i=1:length(x)
                indicator.append(MG2.Vertex((8/length(x))*[x(i),y(i)]));
            end

            indicator.Position=pos-[1,1];


