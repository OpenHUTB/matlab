function testList=listTestSpecial







    testList={
    '$position = ''right''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:rightPositionLabel'))
    '$position = ''center''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:centerPositionLabel'))
    '$position = ''left''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:leftPositionLabel'))
    '$sequence = ''odd''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:oddPageLabel'))
    '$sequence = ''even''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:evenPageLabel'))
    '$sequence = ''first''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:firstPageInChapterLabel'))
    '$sequence = ''blank''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:blankPageLabel'))
    '$pageclass = ''titlepage''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:titlepageLabel'))
    '$double.sided != 0',getString(message('rptgen:RptgenML_StylesheetHeaderCell:doubleSidedLabel'))
    '$double.sided != 0 and ($sequence = ''even'' or $sequence = ''blank'') and $position = ''left''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:doubleSidedOuterLeftLabel'))
    '$double.sided != 0 and ($sequence = ''odd'' or $sequence = ''first'') and $position = ''right''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:doubleSidedOuterRightLabel'))
    '$double.sided = 0',getString(message('rptgen:RptgenML_StylesheetHeaderCell:singleSidedLabel'))
    '$double.sided = 0 and $position=''center''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:singleSidedCenterLabel'))
    '($sequence=''odd'' or $sequence=''even'') and $position=''center'' and $pageclass != ''titlepage''',getString(message('rptgen:RptgenML_StylesheetHeaderCell:bodyPageCenterLabel'))
    '',getString(message('rptgen:RptgenML_StylesheetHeaderCell:customConditionLabel'))
    };

