var Validation = function () {

    return {
        
        //Validation
        initValidation: function () {
	        $(".sky-form").validate({                   
	            // Rules for form validation
	            rules:
	            {
	                required:
	                {
	                    required: true
	                },
	                email:
	                {
	                    email: true
	                },
	                url:
	                {
	                    url: true
	                },
	                date:
	                {
	                    date: true
	                },
	                min:
	                {
	                    minlength: 5
	                },
	                max:
	                {
	                    maxlength: 5
	                },
	                range:
	                {
	                    rangelength: [5, 10]
	                },
	                digits:
	                {
	                    digits: true
	                },
	                number:
	                {
	                    number: true
	                },
	                minVal:
	                {
	                    min: 5
	                },
	                maxVal:
	                {
	                    max: 100
	                },
	                rangeVal:
	                {
	                    range: [5, 100]
	                }
	            },
	                                
	            // Messages for form validation
	            messages:
	            {
	                required:
	                {
	                    required: 'Please enter something'
	                },
	                email:
	                {
	                    required: 'Please enter your email address'
	                },
	                url:
	                {
	                    required: 'Please enter your URL'
	                },
	                date:
	                {
	                    required: 'Please enter some date'
	                },
	                min:
	                {
	                    required: 'Please enter some text'
	                },
	                max:
	                {
	                    required: 'Please enter some text'
	                },
	                range:
	                {
	                    required: 'Please enter some text'
	                },
	                digits:
	                {
	                    required: 'Please enter some digits'
	                },
	                number:
	                {
	                    required: 'Please enter some number'
	                },
	                minVal:
	                {
	                    required: 'Please enter some value'
	                },
	                maxVal:
	                {
	                    required: 'Please enter some value'
	                },
	                rangeVal:
	                {
	                    required: 'Please enter some value'
	                }
	            },                  
	            
	            // Do not change code below
	            errorPlacement: function(error, element)
	            {
	                error.insertAfter(element.parent());
	            }
	        });
        }

    };
}();

jQuery(document).ready(function() {
	Validation.initValidation();
});