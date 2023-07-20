function desc=doGetDataDescriptors(hObj,index,~)









    numgrp=hObj.XNumGroups;
    xgrp=hObj.XGroupNames;


    isnotch=strcmp(hObj.Notch,'on');

    if index>numgrp

        desc=getOutlierDescriptors(hObj,index-numgrp,xgrp);
    else

        desc=getFaceAndWhiskerDescriptors(hObj,index,xgrp,isnotch);
    end
end

function desc=getOutlierDescriptors(hObj,index,xgrp)


    gStats=hObj.GroupStatistics;


    out=gStats.NumOutliers;
    out(out==0)=1;
    xind=find((cumsum(out)-index)>=0);
    xind=xind(1);


    bnumout=gStats.NumOutliers(xind);
    isvert=strcmpi(hObj.Orientation_I,'vertical');
    bydata=hObj.OutlierVertexData(index,1+isvert);


    xgroup=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:Position')),xgrp(xind));
    ydata=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:OutlierValue')),bydata);
    numout=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:NumOutliers')),bnumout);
    colgrp=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:ColorGroup')),hObj.DisplayName);


    desc=xgroup;
    if strcmp(hObj.GroupByColorMode,'manual')
        desc=[desc,colgrp];
    end
    desc=[desc,ydata,numout];
end

function desc=getFaceAndWhiskerDescriptors(hObj,xind,xgrp,isnotch)


    gStats=hObj.GroupStatistics;

    bmed=gStats.Median(xind);
    bquart=[gStats.BoxLower(xind),gStats.BoxUpper(xind)];
    bwhisk=[gStats.WhiskerLower(xind),gStats.WhiskerUpper(xind)];
    bnotch=gStats.Notch(:,xind)';
    bnumpts=gStats.NumPoints(xind);


    xgroup=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:Position')),xgrp(xind));
    numpts=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:NumPoints')),bnumpts);
    med=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:Median')),bmed);
    quart=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:Quartiles')),bquart);
    whisk=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:Whiskers')),bwhisk);
    notch=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:Notches')),bnotch);
    colgrp=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
    getString(message('MATLAB:graphics:boxchart:ColorGroup')),hObj.DisplayName);


    desc=xgroup;
    if strcmp(hObj.GroupByColorMode,'manual')
        desc=[desc,colgrp];
    end
    desc=[desc,numpts,med,quart,whisk];
    if isnotch
        desc=[desc,notch];
    end
end
