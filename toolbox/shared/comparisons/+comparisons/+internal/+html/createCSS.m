function htmloutput=createCSS()




    htmloutput=cell(100,1);
    currentline=1;

    function writeLine(str,varargin)
        htmloutput{currentline}=sprintf(str,varargin{:});
        currentline=currentline+1;
    end



    writeLine('<style type="text/css">\n');


    writeLine('pre {\n');
    writeLine('  display:inline-block;\n');
    writeLine('}\n');

    import com.mathworks.comparisons.util.ColorUtils;
    import com.mathworks.comparisons.prefs.TwoSourceColorProfile;
    color=ColorUtils.getColor(TwoSourceColorProfile.MODIFIED_LINE_COLOR_NAME);
    color=ColorUtils.colorToHTMLString(color);
    writeLine('.diffnomatch {\n');
    writeLine('  background: %s;\n',char(color));
    writeLine('     display: inline-block;\n');
    writeLine('}\n');
    color=ColorUtils.getColor(TwoSourceColorProfile.RIGHT_DIFFERENCE_COLOR_NAME);
    color=ColorUtils.colorToHTMLString(color);
    writeLine('.right {\n');
    writeLine('  background: %s;\n',char(color));
    writeLine('     display: inline-block;\n');
    writeLine('}\n');
    color=ColorUtils.getColor(TwoSourceColorProfile.LEFT_DIFFERENCE_COLOR_NAME);
    color=ColorUtils.colorToHTMLString(color);
    writeLine('.left {\n');
    writeLine('  background: %s;\n',char(color));
    writeLine('     display: inline-block;\n');
    writeLine('}\n');
    writeLine('.diffsoft {\n');
    writeLine('    color: #888;\n');
    writeLine('}\n');
    color=java.awt.Color(0.88,0.88,0.88);
    color=ColorUtils.colorToHTMLString(color);
    writeLine('.diffskip {\n');
    writeLine('       color: #888;\n');
    writeLine('  background: %s;\n',char(color));
    writeLine('     display: inline-block;\n');
    writeLine('}\n');

    writeLine('.bold {\n');
    writeLine('  font-weight:bold;\n');
    writeLine('}\n');






    color=ColorUtils.getColor(TwoSourceColorProfile.MERGED_COLOR_NAME);
    color=ColorUtils.colorToHTMLString(color);
    writeLine('.merged {\n');
    writeLine('  background-color: %s;\n',char(color));
    writeLine('           display: inline-block;\n');
    writeLine('}\n');

    writeLine('</style>');

    htmloutput=sprintf('%s\n',htmloutput{1:currentline-1});

end

