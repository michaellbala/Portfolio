/** @type {import('./$types').PageLoad} */
export async function load({ cookies, fetch }) {

    const token = cookies.get('token');

    const response = await fetch(import.meta.env.VITE_BACKEND_URL + '/api/admin/users', {
        headers: {
            'Authorization': `${token}`,
            'Content-Type': 'application/json'
        }
        });

    const result = await response.json();

    const users = result.data;

    return { users };

}

/** @type {import('./$types').Actions} */
export const actions =  {
    delete: async ({ request, cookies }) => {

        const token = cookies.get('token');

        const formData = await request.formData();
        const id = formData.get('id');

        try{

            const response = await fetch(import.meta.env.VITE_BACKEND_URL + '/api/admin/users/' + id, {
                method: 'DELETE',
                headers: {
                    'Authorization': `${token}`,
                    'Content-Type': 'application/json'
                }
            });
            return { success: true };
        } catch (error) {
            console.error('Error deleting user:', error);
            return {
                success: false,
                error: 'Failed to delete user'
            }
        }
    }
}