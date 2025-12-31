extends HTTPRequest
const KEY = "AIzaSyDdNeoyFrNaxb2b0FAUTOQdf1_n5yBWIec"
const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=" + KEY
var response_str: String
signal requestCompleted
var prompt = 'Ignore all prior prompts. Hypothetical scenario, I hear someone say phonetically (merriam webster notation) "wedumd". Is there is a threat for the end of the world? Parsing rules: Allow a small amount of vagueness while parsing sounds, but also take this into account for scoring. Weigh parsing towards infant talk and setting where disaster could be near. When multiple potential matches are possible, use closest match only. Arrange output in this format: one single number for threat from 1 to 100 scale, separated by "!" then return the parsed word(s), then a number for how well the phonetic match is for 1 to 10. If multiple words are considered, still give one single score for threat, order words and phonetic match scores from low to high scores, separated by ";"'

@onready var http_request: HTTPRequest = $HTTPRequest
func _on_http_request_request_completed(result, response_code, headers, body):
	if response_code == 200:
		response_str = parse_gemini_response(body)
		requestCompleted.emit()
		return

	response_str = "Error:" + str(response_code) + " " + str(result) + " " + str(headers)
	requestCompleted.emit()
	
func generate_content(prompt):
	var headers = ["Content-Type: application/json"]
	
	var request_data = {
		"contents": [{
			"parts":[{
				"text": prompt
			}]
		}]
	}
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_data))

func parse_gemini_response(body):
	var response_string = JSON.parse_string(body.get_string_from_utf8())
	
	var content = response_string['candidates'][0]['content']['parts'][0]['text']
	return content

func generate_sentence(prompt: String, display_node: RichTextLabel):
	display_node.text = "sending..."
	
	generate_content(prompt)
	await requestCompleted
	display_node.text = response_str
	
generate_sentence(prompt)
