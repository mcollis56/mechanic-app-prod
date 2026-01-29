import { ref, computed } from 'vue'
import { supabase } from '@/supabaseClient.js'

/**
 * Composable for vehicle management
 * Provides CRUD operations and search functionality for vehicles
 */
export function useVehicles() {
    const vehicles = ref([])
    const loading = ref(false)
    const error = ref(null)

    /**
     * Fetch all vehicles with customer information
     */
    const fetchVehicles = async () => {
        try {
            loading.value = true
            error.value = null

            const { data, error: fetchError } = await supabase
                .from('vehicles')
                .select(`
          *,
          customers (
            id,
            name,
            email,
            phone
          )
        `)
                .order('created_at', { ascending: false })

            if (fetchError) throw fetchError

            vehicles.value = data || []
            return data
        } catch (err) {
            error.value = err.message
            console.error('Error fetching vehicles:', err)
            throw err
        } finally {
            loading.value = false
        }
    }

    /**
     * Fetch a single vehicle by ID
     */
    const fetchVehicleById = async (id) => {
        try {
            loading.value = true
            error.value = null

            const { data, error: fetchError } = await supabase
                .from('vehicles')
                .select(`
          *,
          customers (
            id,
            name,
            email,
            phone
          )
        `)
                .eq('id', id)
                .single()

            if (fetchError) throw fetchError

            return data
        } catch (err) {
            error.value = err.message
            console.error('Error fetching vehicle:', err)
            throw err
        } finally {
            loading.value = false
        }
    }

    /**
     * Fetch vehicles for a specific customer
     */
    const fetchVehiclesByCustomer = async (customerId) => {
        try {
            loading.value = true
            error.value = null

            const { data, error: fetchError } = await supabase
                .from('vehicles')
                .select('*')
                .eq('customer_id', customerId)
                .order('created_at', { ascending: false })

            if (fetchError) throw fetchError

            return data || []
        } catch (err) {
            error.value = err.message
            console.error('Error fetching customer vehicles:', err)
            throw err
        } finally {
            loading.value = false
        }
    }

    /**
     * Search vehicles by multiple fields
     */
    const searchVehicles = async (searchTerm) => {
        try {
            loading.value = true
            error.value = null

            if (!searchTerm || searchTerm.trim() === '') {
                return await fetchVehicles()
            }

            const term = searchTerm.toLowerCase().trim()

            // Search across multiple fields
            const { data, error: searchError } = await supabase
                .from('vehicles')
                .select(`
          *,
          customers (
            id,
            name,
            email,
            phone
          )
        `)
                .or(`vin.ilike.%${term}%,registration.ilike.%${term}%,make.ilike.%${term}%,model.ilike.%${term}%`)

            if (searchError) throw searchError

            vehicles.value = data || []
            return data
        } catch (err) {
            error.value = err.message
            console.error('Error searching vehicles:', err)
            throw err
        } finally {
            loading.value = false
        }
    }

    /**
     * Create a new vehicle
     */
    const createVehicle = async (vehicleData) => {
        try {
            loading.value = true
            error.value = null

            const { data, error: createError } = await supabase
                .from('vehicles')
                .insert([vehicleData])
                .select()
                .single()

            if (createError) throw createError

            // Refresh the list
            await fetchVehicles()

            return data
        } catch (err) {
            error.value = err.message
            console.error('Error creating vehicle:', err)
            throw err
        } finally {
            loading.value = false
        }
    }

    /**
     * Update an existing vehicle
     */
    const updateVehicle = async (id, vehicleData) => {
        try {
            loading.value = true
            error.value = null

            const { data, error: updateError } = await supabase
                .from('vehicles')
                .update(vehicleData)
                .eq('id', id)
                .select()
                .single()

            if (updateError) throw updateError

            // Refresh the list
            await fetchVehicles()

            return data
        } catch (err) {
            error.value = err.message
            console.error('Error updating vehicle:', err)
            throw err
        } finally {
            loading.value = false
        }
    }

    /**
     * Delete a vehicle
     */
    const deleteVehicle = async (id) => {
        try {
            loading.value = true
            error.value = null

            const { error: deleteError } = await supabase
                .from('vehicles')
                .delete()
                .eq('id', id)

            if (deleteError) throw deleteError

            // Refresh the list
            await fetchVehicles()

            return true
        } catch (err) {
            error.value = err.message
            console.error('Error deleting vehicle:', err)
            throw err
        } finally {
            loading.value = false
        }
    }

    /**
     * Get service history for a vehicle
     */
    const getServiceHistory = async (vehicleId) => {
        try {
            const { data, error: fetchError } = await supabase
                .from('service_history')
                .select(`
          *,
          profiles (
            id,
            email
          )
        `)
                .eq('vehicle_id', vehicleId)
                .order('service_date', { ascending: false })

            if (fetchError) throw fetchError

            return data || []
        } catch (err) {
            console.error('Error fetching service history:', err)
            throw err
        }
    }

    // Computed properties
    const vehicleCount = computed(() => vehicles.value.length)
    const hasVehicles = computed(() => vehicles.value.length > 0)

    return {
        // State
        vehicles,
        loading,
        error,

        // Computed
        vehicleCount,
        hasVehicles,

        // Methods
        fetchVehicles,
        fetchVehicleById,
        fetchVehiclesByCustomer,
        searchVehicles,
        createVehicle,
        updateVehicle,
        deleteVehicle,
        getServiceHistory
    }
}
