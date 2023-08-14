function ret=isAltTextForDocEnabled






    ret=~isempty(getenv('IS_PUBLISHING'))&&isempty(getenv('DISABLE_FIGURE_ALT_TEXT_CREATION'));