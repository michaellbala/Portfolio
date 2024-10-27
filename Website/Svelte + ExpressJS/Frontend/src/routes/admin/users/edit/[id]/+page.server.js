import {fail} from '@sveltejs/kit';

/** @type {import('./$types').PageLoad} */
export async function load({ params, fetch, cookies }) {
    
    const token = cookies.get('token');

    const response = await fetch(import.meta.env.VITE_BACKEND_URL + '/api/admin/users/' + params.id, {
        headers: {
            'Authorization': `${token}`,
            'Content-Type': 'application/json'
        }
        });

    const result = await response.json();

    const user = result.data;

    return { user };
}

/** @type {import('./$types').Actions} */
export const actions =  {
    update: async ({ request, params, cookies }) => {
        try {
            const token = cookies.get('token');

            const formData = await request.formData();

            const name = formData.get('name');
            const email = formData.get('email');
            const password = formData.get('password');

            const response = await fetch(import.meta.env.VITE_BACKEND_URL + '/api/admin/users/' + params.id, {
                method: 'PUT',
                headers: {
                    'Authorization': `${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    name,
                    email,
                    password
                })
            });

            const result = await response.json();

            if (!response.ok) {
                return fail(response.status, {
                    success: false,
                    message: result.message || 'Something went wrong',
                    errors: result.errors || [],
                    values: { name, email }
                });
            }

            return { success: true, message: 'User updated successfully' };
        } catch (error) {
            if (error instanceof Error) {
                return {
                    success: false,
                    message: error.message
                }
            }
            console.error('Error:', error);
            return fail(500, {
                success: false,
                message: 'Something went wrong'
            });
                }
    }
}