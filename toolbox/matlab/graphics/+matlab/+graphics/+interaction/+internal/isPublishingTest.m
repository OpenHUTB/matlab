function ret=isPublishingTest

    ret=~isempty(getenv('IS_PUBLISHING'));