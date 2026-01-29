/**
 * AI Service for mechanic shop application
 * Provides AI-powered features like note enhancement and workflow suggestions
 */

const AI_ENABLED = import.meta.env.VITE_AI_ENABLED === 'true'
const AI_PROVIDER = import.meta.env.VITE_AI_PROVIDER || 'claude'
const ANTHROPIC_API_KEY = import.meta.env.VITE_ANTHROPIC_API_KEY
const OPENAI_API_KEY = import.meta.env.VITE_OPENAI_API_KEY

export class AIService {
    constructor() {
        this.enabled = AI_ENABLED
        this.provider = AI_PROVIDER
    }

    /**
     * Check if AI is enabled and configured
     */
    isAvailable() {
        if (!this.enabled) return false

        if (this.provider === 'claude' && !ANTHROPIC_API_KEY) return false
        if (this.provider === 'openai' && !OPENAI_API_KEY) return false

        return true
    }

    /**
     * Enhance technician notes to be customer-friendly
     * @param {string} technicianNotes - Raw notes from technician (shorthand)
     * @param {object} context - Additional context (vehicle, customer, job type)
     * @returns {Promise<string>} - Enhanced customer-friendly notes
     */
    async enhanceNotes(technicianNotes, context = {}) {
        if (!this.isAvailable()) {
            throw new Error('AI service is not available. Please configure API keys.')
        }

        const prompt = this.buildNotesPrompt(technicianNotes, context)

        try {
            if (this.provider === 'claude') {
                return await this.callClaude(prompt)
            } else if (this.provider === 'openai') {
                return await this.callOpenAI(prompt)
            }
        } catch (error) {
            console.error('AI enhancement error:', error)
            throw new Error(`Failed to enhance notes: ${error.message}`)
        }
    }

    /**
     * Generate service history summary for a vehicle
     * @param {Array} serviceHistory - Array of service records
     * @returns {Promise<string>} - Summary of service history
     */
    async generateServiceSummary(serviceHistory) {
        if (!this.isAvailable()) {
            throw new Error('AI service is not available')
        }

        const prompt = `Based on the following service history, provide a concise summary of the vehicle's maintenance:

${serviceHistory.map((service, index) => `
${index + 1}. ${service.service_date}: ${service.service_type}
   ${service.description}
   Cost: $${service.cost}
`).join('\n')}

Provide a 2-3 sentence summary highlighting key maintenance patterns and any concerns.`

        try {
            if (this.provider === 'claude') {
                return await this.callClaude(prompt)
            } else if (this.provider === 'openai') {
                return await this.callOpenAI(prompt)
            }
        } catch (error) {
            console.error('AI summary error:', error)
            throw new Error(`Failed to generate summary: ${error.message}`)
        }
    }

    /**
     * Suggest next workflow steps based on job details
     * @param {object} jobDetails - Current job information
     * @returns {Promise<Array>} - Suggested next steps
     */
    async suggestWorkflow(jobDetails) {
        if (!this.isAvailable()) {
            throw new Error('AI service is not available')
        }

        const prompt = `Based on this automotive repair job, suggest the next 3-5 workflow steps:

Job Type: ${jobDetails.problem_description || 'General service'}
Current Status: ${jobDetails.status || 'New'}
Vehicle: ${jobDetails.vehicle_make} ${jobDetails.vehicle_model} (${jobDetails.vehicle_year || 'Unknown year'})
Notes: ${jobDetails.technician_notes || 'No notes yet'}

Provide a numbered list of specific, actionable next steps.`

        try {
            let response
            if (this.provider === 'claude') {
                response = await this.callClaude(prompt)
            } else if (this.provider === 'openai') {
                response = await this.callOpenAI(prompt)
            }

            // Parse the response into an array of steps
            const steps = response
                .split('\n')
                .filter(line => /^\d+\./.test(line.trim()))
                .map(line => line.replace(/^\d+\.\s*/, '').trim())

            return steps
        } catch (error) {
            console.error('AI workflow suggestion error:', error)
            throw new Error(`Failed to suggest workflow: ${error.message}`)
        }
    }

    /**
     * Build prompt for note enhancement
     */
    buildNotesPrompt(technicianNotes, context) {
        return `You are an automotive service advisor. Convert the following technician's shorthand notes into professional, customer-friendly language.

Technician Notes: ${technicianNotes}

${context.vehicle ? `Vehicle: ${context.vehicle.make} ${context.vehicle.model} (${context.vehicle.year || 'Unknown year'})` : ''}
${context.customer ? `Customer: ${context.customer.name}` : ''}
${context.jobType ? `Job Type: ${context.jobType}` : ''}

Guidelines:
- Use clear, professional language
- Explain technical terms in simple words
- Be honest but reassuring
- Focus on what was done and why it matters
- Keep it concise (2-3 paragraphs max)

Provide only the enhanced notes, no preamble.`
    }

    /**
     * Call Claude API
     */
    async callClaude(prompt) {
        const response = await fetch('https://api.anthropic.com/v1/messages', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-api-key': ANTHROPIC_API_KEY,
                'anthropic-version': '2023-06-01'
            },
            body: JSON.stringify({
                model: 'claude-3-5-sonnet-20241022',
                max_tokens: 1024,
                messages: [
                    {
                        role: 'user',
                        content: prompt
                    }
                ]
            })
        })

        if (!response.ok) {
            const error = await response.json()
            throw new Error(error.error?.message || 'Claude API request failed')
        }

        const data = await response.json()
        return data.content[0].text
    }

    /**
     * Call OpenAI API
     */
    async callOpenAI(prompt) {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${OPENAI_API_KEY}`
            },
            body: JSON.stringify({
                model: 'gpt-4-turbo-preview',
                messages: [
                    {
                        role: 'system',
                        content: 'You are an automotive service advisor helping to communicate technical information to customers.'
                    },
                    {
                        role: 'user',
                        content: prompt
                    }
                ],
                max_tokens: 1024,
                temperature: 0.7
            })
        })

        if (!response.ok) {
            const error = await response.json()
            throw new Error(error.error?.message || 'OpenAI API request failed')
        }

        const data = await response.json()
        return data.choices[0].message.content
    }
}

// Export singleton instance
export const aiService = new AIService()

// Export helper function for components
export function useAI() {
    return {
        aiService,
        isAIAvailable: aiService.isAvailable()
    }
}
