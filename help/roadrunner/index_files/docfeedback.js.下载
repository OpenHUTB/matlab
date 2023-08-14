/* eslint-disable no-unused-vars */
/* Disabling the eslint check because this function will be called from HTML: especially, initDocSurvey shouldn't be called before Saxon-JS finishes loading the other content. */
function loadSurveyHidden () {
    var d = document.createElement('div');
    var docLang = '';
    var docLangNode = document.getElementById('doc_center_content');
    if (docLangNode != null) {
        docLang = document.getElementById('doc_center_content').dataset.language;
    }
    d.innerHTML = '<mw-rating-feedback id="declarative" forwardLabel="Submit" forwardLabelAria="Submit"><mw-rating-feedback-step step="0">How useful was this information?</mw-rating-feedback-step><mw-rating-feedback-step step="1">Why did you choose this rating?</mw-rating-feedback-step><mw-rating-feedback-step step="2"><span class="glyphicon glyphicon-ok" style="display: inline-block !important; color: #008013"></span>Thank you for your feedback!</mw-rating-feedback-step></mw-rating-feedback>';
    if (docLang === 'es') {
        d.innerHTML = '<mw-rating-feedback id="declarative" forwardLabel="Submit" forwardLabelAria="Submit"><mw-rating-feedback-step step="0">¿Qué tan útil fue esta traducción?</mw-rating-feedback-step><mw-rating-feedback-step step="1">¿Por qué eligió esta calificación?</mw-rating-feedback-step><mw-rating-feedback-step step="2"><span class="glyphicon glyphicon-ok" style="display: inline-block !important; color: #008013"></span>¡Gracias por sus comentarios!</mw-rating-feedback-step></mw-rating-feedback>';
    } else if (docLang === 'ja_JP') {
        d.innerHTML = '<mw-rating-feedback id="declarative" forwardLabel="Submit" forwardLabelAria="Submit"><mw-rating-feedback-step step="0">この情報は役に立ちましたか？</mw-rating-feedback-step><mw-rating-feedback-step step="1">評価の理由をお聞かせください。</mw-rating-feedback-step><mw-rating-feedback-step step="2"><span class="glyphicon glyphicon-ok" style="display: inline-block !important; color: #008013"></span>ご意見をありがとうございました!</mw-rating-feedback-step></mw-rating-feedback>';
    } else if (docLang === 'ko_KR') {
        d.innerHTML = '<mw-rating-feedback id="declarative" forwardLabel="Submit" forwardLabelAria="Submit"><mw-rating-feedback-step step="0">이 페이지가 얼마나 도움이 되었습니까?</mw-rating-feedback-step><mw-rating-feedback-step step="1">이렇게 평가하신 이유는 무엇입니까?</mw-rating-feedback-step><mw-rating-feedback-step step="2"><span class="glyphicon glyphicon-ok" style="display: inline-block !important; color: #008013"></span>의견을 주셔서 감사합니다!</mw-rating-feedback-step></mw-rating-feedback>';
    } else if (docLang === 'zh_CN') {
        d.innerHTML = '<mw-rating-feedback id="declarative" forwardLabel="Submit" forwardLabelAria="Submit"><mw-rating-feedback-step step="0">本页内容对您有帮助吗？</mw-rating-feedback-step><mw-rating-feedback-step step="1">能告诉我们您的评分理由吗？</mw-rating-feedback-step><mw-rating-feedback-step step="2"><span class="glyphicon glyphicon-ok" style="display: inline-block !important; color: #008013"></span>感谢您的反馈！</mw-rating-feedback-step></mw-rating-feedback>';
    }
    var node = document.getElementById('mw_docsurvey');
    node.style.display = 'none';
    var surveyLoaded = document.getElementById('declarative');
    if (!surveyLoaded) {
        node.appendChild(d);
    }
}

function initDocSurvey () {
    var surveyNode = document.getElementById('mw_docsurvey');
    surveyNode.style.display = '';
}
