function link=generateShowDiffLink(file1,file2)
    link=['<a href = "matlab: visdiff ',file1,' ',file2,'"> ',DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_showdiff'),' </a>'];
end
