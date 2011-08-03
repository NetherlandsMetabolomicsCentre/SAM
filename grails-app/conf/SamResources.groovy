modules = {
	sam2 {
		dependsOn 'datatables'
		
		resource url: 'js/selectAddMore.js'
		resource url: 'js/removeWebFlowExecutionKey.js'
		resource url: 'css/sam.css'
		resource url: 'css/tooltip.css'
        resource url:'/images/subjectlayout.png', attrs:[alt:''], disposition:'inline'
        resource url:'/images/samplelayout.png', attrs:[alt:''], disposition:'inline'
	}
}